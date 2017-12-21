function NIIds = dp_downsample_nifti(nifti_fn, dsrate)
% Requires nifti toolbox
% dsrate = 8;
% 
% nifti_fn = '/imaging/dp01/templates/HarvardOxford-cort-maxprob-thr25-1mm.nii';

!cp '/imaging/local/software/fsl/latest/x86_64/fsl/data/atlases/HarvardOxford/HarvardOxford-cort-maxprob-thr25-1mm.nii.gz' /imaging/dp01/templates/
gunzip('/imaging/dp01/templates/HarvardOxford-cort-maxprob-thr25-1mm.nii.gz');
NII1mm = load_nii(nifti_fn);

T1mm = [NII1mm.hdr.hist.srow_x; NII1mm.hdr.hist.srow_y; NII1mm.hdr.hist.srow_z; [0 0 0 1]];

minmni = [0 0 0 1] * T1mm';
maxmni = [size(NII1mm.img) 1] * T1mm';

[m1x, m1y, m1z] = ndgrid(1:size(NII1mm.img,1), 1:size(NII1mm.img,2), 1:size(NII1mm.img, 3));

m1xyz = [m1x(:) m1y(:) m1z(:) ones(size(m1z(:)))] * T1mm';

sz = size(NII1mm.img)/dsrate;

[mdx, mdy, mdz] = ndgrid(0:sz(1)-1, 0:sz(2)-1, 0:sz(3)-1);

Td(1:3,1:3) = T1mm(1:3,1:3)*dsrate;
Td(1:4,4) = T1mm(:,4);

mdxyz = [mdx(:) mdy(:) mdz(:) ones(size(mdz(:)))] * Td';
mdxyz = mdxyz(:,1:3);

dsf = floor(sz);

NIIds = NII1mm;

NIIds.img = interpn(reshape(m1xyz(:,1),size(NII1mm.img)), reshape(m1xyz(:,2),size(NII1mm.img)), reshape(m1xyz(:,3),size(NII1mm.img)),...
    double(NII1mm.img), reshape(mdxyz(:,1),dsf), reshape(mdxyz(:,2),dsf), reshape(mdxyz(:,3),dsf));

NIIds.hdr.hist.srow_x = Td(1,:);
NIIds.hdr.hist.srow_y = Td(2,:);
NIIds.hdr.hist.srow_z = Td(3,:);
NIIds.hdr.hist.originator(1:4) = NII1mm.hdr.hist.originator(1:4) / dsrate;



