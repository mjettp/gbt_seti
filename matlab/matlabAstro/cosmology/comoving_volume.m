function [dVc,Vc]=comoving_volume(Z,CosmoPars)
%------------------------------------------------------------------------------
% comoving_volume function                                           cosmology
% Description: Calculate the differential comoving volume (d\Omega dz)
%              at redshift z and the total comoving volume from redshift
%              0 to z.
% Input  : - Redshift.
%          - Cosmological parameters:
%            [H0, \Omega_{m}, \Omega_{\Lambda}, \Omega_{radiation}],
%            or cosmological parmeters structure, or a string containing
%            parameters source name, default is 'wmap3' (see cosmo_pars.m).
%            Default for Omega_radiation is 0.
% Output : - Differential comoving volume (d\Omega dz) at redshift z [pc^3] 
%          - Comoving volume from redshift 0 to z [pc^3].
% Reference : http://nedwww.ipac.caltech.edu/level5/Hogg/frames.html
% Tested : Matlab 7.0
%     By : Eran O. Ofek                    August 2006
%    URL : http://wise-obs.tau.ac.il/~eran/matlab.html
% Reliable: 2
%------------------------------------------------------------------------------

if (nargin==1),
  CosmoPars = 'wmap3';
elseif (nargin==2),
   % do nothing
else
   error('Illegal number of input arguments');
end


if (isstr(CosmoPars)==0 & isstruct(CosmoPars)==0),
   % do nothing
else
   Par = cosmo_pars(CosmoPars);
   CosmoPars = [Par.H0, Par.OmegaM, Par.OmegaL, Par.OmegaRad];
end
if (length(CosmoPars)==3),
   CosmoPars(4) = 0;
end


OmegaPars = CosmoPars(2:end);
H0        = CosmoPars(1);
C         = get_constant('c','cgs');
DH        = C./(H0.*1e5) .*1e6;               % [pc]

% OmegaPars(3) is not implemented in ad_dist
DA = ad_dist(Z,CosmoPars);  % pc

Ez = e_z(Z,CosmoPars);

dVc = DH.*((1+Z).*DA).^2./Ez;

if (nargout>1),
   % calculate comoving distance
   DM = tran_comoving_dist(Z,CosmoPars);   % pc


   OmegaK = 1 - sum(OmegaPars);

   Ip  = find(OmegaK>0);
   I0  = find(OmegaK==0);
   In  = find(OmegaK<0);

   switch sign(OmegaK)
    case 1
       Vc  = (4.*pi.*DH.^3./(2.*OmegaK)).* (DM./DH .* sqrt(1 + OmegaK.*(DM./DH).^2) - ...
	      1./sqrt(abs(OmegaK)) .*asinh(sqrt(abs(OmegaK)).*DM./DH));
    case 0
       Vc  = 4.*pi./3 .* DM.^3;
    case -1
       Vc  = (4.*pi.*DH.^3./(2.*OmegaK)).* (DM./DH .* sqrt(1 + OmegaK.*(DM./DH).^2) - ...
	     1./sqrt(abs(OmegaK)) .*asin(sqrt(abs(OmegaK)).*DM./DH));
    otherwise
       error('Unknown value for OmegaK');
   end
end
