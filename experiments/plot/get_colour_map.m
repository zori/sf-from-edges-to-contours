% Zornitsa Kostadinova
% Nov 2014
% 8.3.0.532 (R2014a)
function colours = get_colour_map(experiments)
if nargin<1, experiments=''; end
switch experiments
  case 'mid-masters'
    colours = [
      177,89,40; % baseline - brown
      46, 19, 221; % fst
      46, 19, 221; % oracle 1
      254, 40, 162; % snd
      254, 40, 162; % oracle 2
      19, 221, 221; % third
      19, 221, 221; % oracle 3
      30, 144, 255;
      0, 0, 0; % SE - black
      255,0,0; % MCG
      238, 130, 238; % N4 Fields - pink
      68, 187, 217; % nice contrast blue
      54, 157, 101; % nice green
      198, 101, 68; % orange, not so great
      163, 163, 163; % grey
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      ]./256;
  otherwise
    % colours for up to 28 curves
    colours = [
      0, 100, 0;
      30, 144, 255;
      75, 0, 130;
      255, 20, 147;
      153, 50, 204;
      238, 130, 238;
      135, 206, 235;
      228, 229, 97;
      0, 250, 154;
      163, 163, 163;
      218, 71, 56;
      219, 135, 45;
      145, 92, 146;
      83, 136, 173;
      255,228,225;
      225, 119, 174;
      142, 195, 129;
      139, 69, 19;
      240, 128, 128;
      92, 172, 158;
      177,89,40;
      0, 255, 255;
      188, 128, 189;
      138, 180, 66;
      255, 255, 0;
      223, 200, 51;
      0, 0, 205;
      135, 130, 174;
      ]./256;
end
end
