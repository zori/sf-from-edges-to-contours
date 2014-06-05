function outvideo=Uintconv(video)
%Convert video into uint8,uint16,uint32 depending on its max value.
%Negative values are assigned to thmax, which should therefore not be used
%as a valid label
%Video converted with this function should be back-converted with
%Doublebackconv

vidmax=max(video(:));

if (vidmax<255)
    uintconverter=@uint8;
    thmax=255;
elseif ( (vidmax>=255) && (vidmax<65535) )
    uintconverter=@uint16;
    thmax=65535;
elseif ( (vidmax>=65535) && (vidmax<4294967295) )
    uintconverter=@uint32;
    thmax=4294967295;
else
%     fprintf('Convertion to not address with this function\n');
    outvideo=video;
    return;
end

outvideo=video;

outvideo(outvideo<0)=thmax;

outvideo=uintconverter(outvideo);


function video=test_conv() %#ok<DEFNU>

video=zeros(5,5,2);
video(1,1,1)=255;
video(1,2,1)=-1;
video=Uintconv(video);
video=Doublebackconv(video);
