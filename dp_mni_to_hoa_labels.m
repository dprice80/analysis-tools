% INPUT

mni = [-52 -34 26]; % input MNI coord here.
% 63 56 50 % should be this in voxel coords (then you need to add 1)

%---------------------
NII = load_nii('/imaging/camcan/templates/HarvardOxford-combo-maxprob-thr25-2mm.nii');

T = [NII.hdr.hist.srow_x; NII.hdr.hist.srow_y; NII.hdr.hist.srow_z; [0 0 0 1]];

voxcoords = [mni 1]*inv(T)'+1;

voxval = NII.img(voxcoords(1), voxcoords(2), voxcoords(3))

Labels = csvimport('/imaging/camcan/templates/HOA116_coords_labels_td.txt','delimiter','\t');

labvals = [Labels{2:end,2}];
labtext = Labels(2:end,6:10);

findlabel = find(labvals == voxval);

disp([labtext(findlabel,:)])

