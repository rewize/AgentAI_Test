% Far-field element pattern and monostatic RCS demonstration.
% Requires MATLAB Antenna Toolbox.

clear;
close all;
clc;

frequency = 3e9;
azimuth = -180:2:180;
elevation = 0;

element = design(dipole, frequency);
mesh(element, MaxEdgeLength=3e8/frequency/10);

% Element radiation pattern in the far field.
elementGain = pattern(element, frequency, azimuth, elevation, ...
	Type="gain", CoordinateSystem="rectangular");

% FMM handles this dipole geometry in the installed MATLAB release.
rcsValue = zeros(size(azimuth));
for angleIndex = 1:numel(azimuth)
	rcsValue(angleIndex) = rcs(element, frequency, azimuth(angleIndex), ...
		elevation, Polarization="VV", Solver="FMM", Scale="linear");
end
rcsDbsm = 10*log10(max(rcsValue, realmin));

figure(Name="Element Far-Field Pattern");
plot(azimuth, elementGain, LineWidth=1.4);
grid on;
xlabel("Azimuth (degrees)");
ylabel("Gain (dBi)");
title("Dipole Element Far-Field Pattern at 3 GHz");

figure(Name="Monostatic RCS");
plot(azimuth, rcsDbsm, LineWidth=1.4);
grid on;
xlabel("Azimuth (degrees)");
ylabel("RCS (dBsm)");
title("Dipole Monostatic RCS at 3 GHz, VV Polarization (FMM)");

[peakGain, peakGainIndex] = max(elementGain);
[peakRcs, peakRcsIndex] = max(rcsDbsm);
fprintf("Frequency: %.3f GHz\n", frequency/1e9);
fprintf("Peak element gain: %.2f dBi at azimuth %.0f degrees\n", ...
	peakGain, azimuth(peakGainIndex));
fprintf("Peak monostatic RCS: %.2f dBsm at azimuth %.0f degrees\n", ...
	peakRcs, azimuth(peakRcsIndex));
