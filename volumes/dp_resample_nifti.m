function NIIds = dp_resample_nifti(nifti_fn, ds)
% Requires nifti toolbox
% ds = either a) downsample rate (scalar). original / new resolution;
%    or b) filename of a reference volume for resampling. The reference volume 
%    must already be in the same space as the input image. 
% nifti_fn = nifti image filename to be downsampled
% OUTPUT
% NIIds = downsampled nifti file
% This tool can also be used to upsample by making ds < 1

NII1mm = load_nii(nifti_fn);

[m1x, m1y, m1z, T1mm] = get_grids(NII1mm);

if ischar(ds)
    NIIds = load_nii(ds);
    [mrx, mry, mrz] = get_grids(NIIds);
    NIIds.img = single(NIIds.img);
    NIIds.hdr.dime.bitpix = 16;
    NIIds.img = interpn(m1x, m1y, m1z, single(NII1mm.img), mrx, mry, mrz);
else
    sz = size(NII1mm.img)/ds;

    [mdx, mdy, mdz] = ndgrid(0:sz(1)-1, 0:sz(2)-1, 0:sz(3)-1);

    Td(1:3,1:3) = T1mm(1:3,1:3)*ds;
    Td(1:4,4) = T1mm(:,4);

    mdxyz = [mdx(:) mdy(:) mdz(:) ones(size(mdz(:)))] * Td';
    mdxyz = mdxyz(:,1:3);
    
    dsf = floor(sz);
    
    NIIds = NII1mm;
    
    NIIds.img = interpn(m1x, m1y, m1z,...
        single(NII1mm.img), reshape(mdxyz(:,1),dsf), reshape(mdxyz(:,2),dsf), reshape(mdxyz(:,3),dsf));
    
    NIIds.hdr.hist.srow_x = Td(1,:);
    NIIds.hdr.hist.srow_y = Td(2,:);
    NIIds.hdr.hist.srow_z = Td(3,:);
    
    NIIds.hdr.hist.originator(1:4) = NIIds.hdr.hist.originator(1:4) / ds;
    NIIds.hdr.dime.dim = [3 size(NIIds.img) 1 1 1 1];
    NIIds.hdr.dime.bitpix = 16;
end

    function [x,y,z,T] = get_grids(NII)
        T = [NII.hdr.hist.srow_x; NII.hdr.hist.srow_y; NII.hdr.hist.srow_z; [0 0 0 1]];
        
        % minmni = [0 0 0 1] * T';
        % maxmni = [size(NII2.img) 1] * T';
        
        [m2x, m2y, m2z] = ndgrid(0:size(NII.img,1)-1, 0:size(NII.img,2)-1, 0:size(NII.img, 3)-1);
        
        m1xyz = [m2x(:) m2y(:) m2z(:) ones(size(m2z(:)))] * T';
        
        sz2 = size(NII.img);
        
        x = reshape(m1xyz(:,1),sz2);
        y = reshape(m1xyz(:,2),sz2);
        z = reshape(m1xyz(:,3),sz2);
        
    end
end
