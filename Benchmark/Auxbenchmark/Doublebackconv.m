function outvideo=Doublebackconv(video)
%Back-convert video from uint8,uint16,uint32 to double.
%Values taking the max theoretcal value thmax (which should therefore not be used
%as a valid label) take -1 in the convertion
%Video back-converted with this function should have been converted with
%Uintconv

if (isa(video,'uint8'))
    thmax=255;
elseif (isa(video,'uint16')) %(isa(video,'uint16') || isa(video,'double'))
    thmax=65535;
elseif (isa(video,'uint32'))
    thmax=4294967295;
else
%     fprintf('Back-convertion to not address with this function\n');
    outvideo=double(video); %Convert to double for compatibility with int16 GTs
    return;
end

outvideo=double(video);

outvideo(video>=thmax)=(-1);

