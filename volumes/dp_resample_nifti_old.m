function NIIds = dp_resample_nifti(nifti_fn, ds)
% Requires nifti toolbox
% ds = either a) downsample rate (scalar). original / new resolution;
%    or b) filename of a reference volume for resampling. The reference volume 
%    must already be in the same space as the input image. 
% nifti_fn = nifti image filename to be downsampled
% OUTPUT
% NIIds = downsampled nifti file
% This tool can also be used to upsample by making ds < 1
% Darren Price - MRC CBU, Cambridge University, UK 2018

if ischar(nifti_fn)
    NIIhires = mni2fs_load_nii(nifti_fn);
elseif isfield(nifti_fn, 'loadmethod') && strcmp(nifti_fn.loadmethod, 'mni2fs')
    NIIhires = nifti_fn;
else
    error('nifti input structure should be loaded using mni2fs_load_nii(), or use a file path instead')
end

[m1x, m1y, m1z] = get_grids(NIIhires);

Thires = NIIhires.transform;

if ischar(ds)
    NIIds = mni2fs_load_nii(ds);
    [mrx, mry, mrz] = get_grids(NIIds);
    NIIds.img = single(NIIds.img);
    NIIds.hdr.dime.bitpix = 16;
    NIIds.img = interpn(m1x, m1y, m1z, single(NIIhires.img), mrx, mry, mrz);
    
elseif isstruct(ds)
    NIIds = ds; clear ds
    [mrx, mry, mrz] = get_grids(NIIds);
    NIIds.img = single(NIIds.img);
    NIIds.hdr.dime.bitpix = 16;
    NIIds.img = interpn(m1x, m1y, m1z, single(NIIhires.img), mrx, mry, mrz);
elseif isnumeric(ds) % then its a number
    sz = size(NIIhires.img)/ds;

    [mdx, mdy, mdz] = ndgrid(0:sz(1)-1, 0:sz(2)-1, 0:sz(3)-1);

    Td(1:3,1:3) = Thires(1:3,1:3)*ds;
    Td(1:4,4) = Thires(:,4);

    mdxyz = [mdx(:) mdy(:) mdz(:) ones(size(mdz(:)))] * Td';
    mdxyz = mdxyz(:,1:3);
    
    dsf = floor(sz);
    
    NIIds = NIIhires;
    
    NIIds.img = interpn(m1x, m1y, m1z,...
        single(NIIhires.img), reshape(mdxyz(:,1),dsf), reshape(mdxyz(:,2),dsf), reshape(mdxyz(:,3),dsf));
    
    NIIds.hdr.hist.srow_x = Td(1,:);
    NIIds.hdr.hist.srow_y = Td(2,:);
    NIIds.hdr.hist.srow_z = Td(3,:);
    
    if isfield(NIIds.hdr.hist,'originator')
        NIIds.hdr.hist.originator(1:4) = NIIds.hdr.hist.originator(1:4) / ds;
    end
    NIIds.hdr.dime.dim = [3 size(NIIds.img) 1 1 1 1];
    NIIds.hdr.dime.bitpix = 16;
    NIIds = mni2fs_load_affine(NIIds);
    NIIds.transform = NIIds.hdr.hist.old_affine;
    NIIds.hdr.dime.pixdim(2:4) = NIIds.hdr.dime.pixdim(2:4)*ds;
else
    error('Input ds should either be a file path, nifti struct loaded using mni2fs_load_nii or a number (downsample rate)')
end


    function [x,y,z] = get_grids(NII)
        T = NII.transform;
        
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
