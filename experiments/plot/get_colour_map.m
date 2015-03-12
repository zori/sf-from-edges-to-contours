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
      254, 40, 162; % snd
      19, 221, 221; % third
      46, 19, 221; % oracle 1
      254, 40, 162; % oracle 2
      19, 221, 221; % oracle 3
      30, 144, 255;
      0, 0, 0; % black
      255,0,0; % red
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      ]./256;
  case 'masters-thesis'
    colours = [
      255,0,0; % red
      255,0,0; % red
      177,89,40; % brown
      0, 100, 0; % baseline - green
      46, 19, 221; % dark blue % fst
      255,0,0; % red
      0, 0, 0; % black
      254, 40, 162; % pink % snd
      19, 221, 221; % light blue-green % third
      75, 0, 130; % purple

      30, 144, 255; % light blue
      75, 0, 130; % purple
      177,89,40; % brown
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      177,89,40; % baseline - brown
      46, 19, 221; % fst
      254, 40, 162; % snd
      19, 221, 221; % third
      46, 19, 221; % oracle 1
      254, 40, 162; % oracle 2
      19, 221, 221; % oracle 3
      30, 144, 255;
      0, 0, 0; % black
      255,0,0; % red
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      177,89,40; % baseline - brown
      46, 19, 221; % fst
      254, 40, 162; % snd
      19, 221, 221; % third
      46, 19, 221; % oracle 1
      254, 40, 162; % oracle 2
      19, 221, 221; % oracle 3
      30, 144, 255;
      0, 0, 0; % black
      255,0,0; % red
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      177,89,40; % baseline - brown
      46, 19, 221; % fst
      254, 40, 162; % snd
      19, 221, 221; % third
      46, 19, 221; % oracle 1
      254, 40, 162; % oracle 2
      19, 221, 221; % oracle 3
      30, 144, 255;
      0, 0, 0; % black
      255,0,0; % red
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      0, 100, 0; % baseline - green
      46, 19, 221; % dark blue % fst
      255,0,0; % red
      0, 0, 0; % black
      254, 40, 162; % pink % snd
      19, 221, 221; % light blue-green % third
      75, 0, 130; % purple

      30, 144, 255; % light blue
      75, 0, 130; % purple
      177,89,40; % brown
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      177,89,40; % baseline - brown
      46, 19, 221; % fst
      254, 40, 162; % snd
      19, 221, 221; % third
      46, 19, 221; % oracle 1
      254, 40, 162; % oracle 2
      19, 221, 221; % oracle 3
      30, 144, 255;
      0, 0, 0; % black
      255,0,0; % red
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      177,89,40; % baseline - brown
      46, 19, 221; % fst
      254, 40, 162; % snd
      19, 221, 221; % third
      46, 19, 221; % oracle 1
      254, 40, 162; % oracle 2
      19, 221, 221; % oracle 3
      30, 144, 255;
      0, 0, 0; % black
      255,0,0; % red
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;
      177,89,40; % baseline - brown
      46, 19, 221; % fst
      254, 40, 162; % snd
      19, 221, 221; % third
      46, 19, 221; % oracle 1
      254, 40, 162; % oracle 2
      19, 221, 221; % oracle 3
      30, 144, 255;
      0, 0, 0; % black
      255,0,0; % red
      198, 101, 68; % orange, not so great
      54, 157, 101; % nice green
      238, 130, 238; % pink
      163, 163, 163; % grey
      68, 187, 217; % nice contrast blue
      225, 119, 174;
      5, 255, 42;
      145, 92, 146;
      255, 118, 0;
      229, 43, 80;

      ]./256;
    
    colours_4_with_oracle_repeated = [
      0, 100, 0; % baseline - green
      254, 40, 162; % pink % snd
      46, 19, 221; % dark blue % fst
      19, 221, 221; % light blue-green % third
      177,89,40; % brown % fourth
      254, 40, 162; % pink % snd
      46, 19, 221; % dark blue % fst
      19, 221, 221; % light blue-green % third
      177,89,40; % brown % fourth
      ]./256;
    % colours=colours_4_with_oracle_repeated;
  otherwise
    % colours for up to 28 curves
    colours = [
      0, 100, 0; % baseline
      30, 144, 255; % light blue
      75, 0, 130; % purple
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
