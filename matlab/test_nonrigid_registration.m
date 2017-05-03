clear all

%Load a mesh
floatingPath = '/home/jonatan/projects/meshmonk/examples/faceTemplate.obj';
floatingPath = '/home/jonatan/projects/meshmonk/examples/ExPeter/floating.obj';
%floatingPath = '/home/jonatan/projects/meshmonk/examples/data/bunny.obj';
[floatingPoints,floatingFaces] = read_vertices_and_faces_from_obj_file(floatingPath);
floatingFaces = uint32(floatingFaces-1); %-1 to make it compatible with C++ indexing
floatingPoints = single(floatingPoints);
floatingNormals = single(zeros(size(floatingPoints)));
compute_normals(floatingPoints, floatingFaces, floatingNormals);
floatingFeatures = single([floatingPoints, floatingNormals]);
numFloatingElements = size(floatingFeatures,1);
floatingFlags = single(ones(numFloatingElements,1));
clear floatingPoints;

%Load a mesh
targetPath = '/home/jonatan/projects/meshmonk/examples/faceTarget.obj';
targetPath = '/home/jonatan/projects/meshmonk/examples/ExPeter/target.obj';
%targetPath = '/home/jonatan/projects/meshmonk/examples/data/bunny2.obj';
[targetPoints,targetFaces] = read_vertices_and_faces_from_obj_file(targetPath);
targetPoints = single(targetPoints);
targetFaces = uint32(targetFaces-1);%-1 to make it compatible with C++ indexing
targetNormals = single(zeros(size(targetPoints)));
compute_normals(targetPoints, targetFaces, targetNormals);
targetFeatures = single([targetPoints, -1.0 * targetNormals]); % WARNING: we had to flip the normals in this case!
numTargetElements = size(targetFeatures,1);
targetFlags = single(ones(numTargetElements,1));
clear targetPoints;

%% Try the mexed pyramid_registration
%mex pyramid_registration.cpp -lmeshmonk

%# Set Parameters
numIterations = 60;
correspondencesSymmetric = true;
correspondencesNumNeighbours = 5;
inlierKappa = 4.0;
inlierUseOrientation = true;
transformSigma = 3.0;
transformNumViscousIterationsStart = 50;
transformNumViscousIterationsEnd = 1;
transformNumElasticIterationsStart = 50;
transformNumElasticIterationsEnd = 1;

nonrigid_registration(floatingFeatures, targetFeatures,...
                      floatingFaces, targetFaces,...
                      floatingFlags, targetFlags,...
                      numIterations,...
                      correspondencesSymmetric, correspondencesNumNeighbours,...
                      inlierKappa, inlierUseOrientation,...
                      transformSigma,...
                      transformNumViscousIterationsStart, transformNumViscousIterationsEnd,...
                      transformNumElasticIterationsStart, transformNumElasticIterationsEnd);

%% Check inliers
correspondingFeatures = single(zeros(numFloatingElements,6));
correspondingFlags = single(ones(numFloatingElements,1));
inlierWeights = single(ones(numFloatingElements,1));

compute_correspondences(floatingFeatures, targetFeatures,...
                        floatingFlags, targetFlags,...
                        correspondingFeatures, correspondingFlags,...
                        correspondencesSymmetric, correspondencesNumNeighbours);
                  
compute_inlier_weights(floatingFeatures, correspondingFeatures,...
                       correspondingFlags, inlierWeights,...
                       inlierKappa, inlierUseOrientation);
                            
%% Write Result
vertface2obj(floatingFeatures(:,1:3),floatingFaces,'/home/jonatan/projects/meshmonk/examples/matlabResult.obj')
                            
                          