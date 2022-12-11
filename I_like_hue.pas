uses GraphABC;
  const clrFileName = 'Hue_colors.csv';
  const w = 6;
  const h = 6;
  const cs = 80;
  
  var gameState: integer; //0 - weelcome, 1 - in game, 2 - victory, 3 - colorZoom
  
  var clrNames: array of string;
  var clrRGBvalues: array[,] of integer;
  var clr: Color;
  var grid: array [1..h, 1..w] of Color;
  var perfectGrid: array [1..h, 1..w] of Color;
  var blockersGrid: array [1..h, 1..w] of boolean;
  var clickedX: integer;
  var clickedY: integer;
  var selectedX := -1;
  var selectedY := -1;
  
procedure FillGrid;
begin
  for var i := 1 to w do
  begin
    for var j := 1 to h do
    begin
      clr := RGB(255-(i - 1)*(255 div w), (j - 1)*(255 div h), (i - 1) *(255 div w));
      grid[i , j] := clr;
      perfectGrid[i, j] := grid[i, j];
    end;
  end;
end;  

procedure DrawRectDSize(x, y :integer; clr : Color; d: integer);
begin
   SetPenColor(grid[x, y]);
   SetBrushColor(grid[x, y]);
   Rectangle((x - 1) * cs - d, (y - 1) * cs - d, x * cs + d, y * cs + d);
   SetPenColor(Color.Black);
   //TextOut((x - 1) * cs + cs div 2, (y - 1) * cs + cs div 2, grid[x, y].G.ToString);
end;

procedure DrawDot(x, y: integer);
begin
  SetBrushColor(color.Black);
  Circle(x * cs - (cs div 2), y * cs - (cs div 2), 6);
end;

procedure DrawRect(x, y :integer; clr : Color);
begin
   DrawRectDSize(x, y, clr, 0);
   if (blockersGrid[x, y] = true) then
    DrawDot(x, y);
end;


procedure DrawGrid;
begin
  for var i := 1 to w do
  begin
    for var j := 1 to h do
    begin
      DrawRect(i, j, grid[i, j]);       
    end;
  end;
end;
  
procedure Swap(x1, y1, x2, y2: integer);
  begin
    clr := grid[x1, y1];
    grid[x1, y1] := grid[x2, y2];
    grid[x2, y2] := clr;
  end;
  
procedure DetermineClickedRect(x, y: integer);
  begin
    clickedX := (x - 1) div cs + 1;
    clickedY := (y - 1) div cs + 1;
  end;
  
procedure DrawSelection();
begin
  //if selectionXY >= 0
  if ((selectedX>=0) and (selectedY>=0)) then
  begin
    //SetBrushColor(Color.Black);
    //Circle((selectedX * cs) - cs div 2, (selectedY * cs) - cs div 2, 8);
  end
end;

procedure AnimateCellUp(x, y: integer); //x, y
begin
  if ((selectedX>=0) and (selectedY>=0)) then
  begin
    DrawRectDSize(x, y, grid[x, y], 2);
    sleep(50);
    DrawRectDSize(x, y, grid[x, y], 4);
    sleep(50);
    DrawRectDSize(x, y, grid[x, y], 6);
  end
end;

procedure AnimateCellDown(x, y: integer);
begin
  if ((selectedX>=0) and (selectedY>=0)) then
  begin
    LockDrawing();
    DrawRectDSize(x, y, grid[x, y], 4);
    Redraw();
    sleep(50);
    DrawGrid();
    DrawRectDSize(x, y, grid[x, y], 3);
    Redraw();
    sleep(50);
    DrawGrid();
    DrawRectDSize(x, y, grid[x, y], 2); 
    Redraw();
    sleep(50);
    UnlockDrawing();
    DrawGrid();
  end
end;

procedure AnimateTwoCellsDown(x1, y1, x2, y2: integer);
begin
  if ((selectedX>=0) and (selectedY>=0)) then
  begin
    LockDrawing();
    DrawRectDSize(x1, y1, grid[x1, y1], 4);
    DrawRectDSize(x2, y2, grid[x2, y2], 4);
    Redraw();
    sleep(50);
    DrawGrid();
    DrawRectDSize(x1, y1, grid[x1, y1], 3);
    DrawRectDSize(x2, y2, grid[x2, y2], 3);
    Redraw();
    sleep(50);
    DrawGrid();
    DrawRectDSize(x1, y1, grid[x1, y1], 2); 
    DrawRectDSize(x2, y2, grid[x2, y2], 2);
    Redraw();
    sleep(50);
    UnlockDrawing();
    DrawGrid();
  end
end;

procedure DetermineWinCondition;
begin
  var isWin := true;
  //for i, j from 1 to w - 1, h  1
  for var i:= 1 to w do
  begin
    for var j := 1 to h do
    begin
      //if (grid[i,j].r > grid[i + 1, j + 1].r
      if ((grid[i, j].r <> perfectGrid[i, j].r)
        or (grid[i, j].g <> perfectGrid[i, j].g)
        or (grid[i, j].b <> perfectGrid[i, j].b)) then
          begin
      //isWin = false and Break
          isWin := false;
          break;
          end
    end
  end;
  
  if(isWin = true) then
  begin
    gameState := 2;
    sleep(600);
    ClearWindow();
    SetBrushColor(clWhite);
    SetFontSize(60);
    TextOut(100, 200,  'You win!')
  end
end;
  
procedure AddBlockers();
begin
  for var i := 1 to w do
  begin
    for var j := 1 to h do
    begin
      if  ((j = h - (h - 1)) or (j = h)) then
      begin
        blockersGrid[i, j] := true;
      end
      else
      begin
        blockersGrid[i, j] := false;
      end;
    end;
  end;
end;

procedure RandomizeGrid();
begin
  //read(t);
  var cnt := 0;
  var t := 1;
  while (cnt <= t) do
    begin
    var r1x := random(w - 1) + 1;
    var r1y := random(h -1) + 1;
    var r2x := random(w - 1) + 1;
    var r2y := random(h) + 1;
  if(blockersGrid[r1x, r1y] <> true) and (blockersGrid[r2x, r2y] <> true) then
    begin
      Swap(r1x, r1y, r2x, r2y);
      cnt := cnt +1;
    end
  end;
end;
  
procedure LoadLevel(l: integer);
begin
  gamestate := 1;
  //if(l = 0) then
  //begin
    //FillGrid();
  //end;
  //if(l = 1) then
  //begin 
    //FillGrid;
    //AddBlockers();
  //end;
  case l of
    0:
      FillGrid;
    1:
    begin
      FillGrid;
      AddBlockers();
    end
  end;
  RandomizeGrid();
end;
 
procedure MouseDownVictory();
begin
  LoadLevel(1);
  sleep(30);
end;

procedure MouseDownStart();
begin
  
end;

procedure MouseDowncColorTip();
begin
  gameState := 1;
  DrawGrid();
end;

procedure LeftMouseClickInGame(x, y: integer);
begin
  DetermineClickedRect(x, y);
  //if nothing is selected then remember clickedXY in selectedXY 
  //(nothing is selected when selxtedXY <= 0)
  if(blockersGrid[clickedX, clickedY] = true) then
      exit;
  if ((selectedX<=0) and (selectedY<=0)) then
  begin
    selectedX := clickedX;
    selectedY := clickedY;
  end      
  else
  begin //if something is already selected - then SWAP grid[selextedXY] with grid[clickedXY]
    Swap(clickedX, clickedY, selectedX, selectedY);
    //AnimateCellDown(clickedX, clickedY); //animate clickedXY
    AnimateTwoCellsDown(clickedX, clickedY, selectedX, selectedY); //animate clickedXY
    selectedX := -1;
    selectedY := -1;
  end;    
  DrawGrid();
  AnimateCellUp(selectedX, selectedY); //animate selectedXY
  DrawSelection(); //draws something on top of grid[selectedXY] if it's > 0
  DetermineWinCondition();
end;

function GetClosestColorName(r, g, b : integer) : string;
begin
  var n := 0;
  var min := 999999;
  //DrawTextCentered(0, 50, cs * w, cs * h, clrRGBvalues.Length div 3);
  for var i := 0 to ((clrRGBvalues.Length div 3) - 1) do
  begin
    var d := sqr(r - clrRGBvalues[i, 0]) + sqr(g - clrRGBvalues[i, 1]) + sqr(b - clrRGBvalues[i, 2]);
    if (d < min) then
    begin
      min := d;
      n := i;
    end
  end;
  
  result := clrNames[n];
end;

procedure RightMouseClickInGame(x, y: integer);
begin
  DetermineClickedRect(x, y);
  SetBrushColor(Grid[clickedX, clickedY]);
  SetPenColor(Color.Black);
  SetFontSize(20);
  Rectangle(0, 0, cs * w, cs * h);
  var c := grid[clickedX, clickedY];
  DrawTextCentered(0, 0, cs * w, cs * h, GetClosestColorName(c.R, c.G, c.B));
  gameState := 3;
end;

procedure MouseDownInGame(x, y, mb: integer);
begin
  if (mb = 1) then
  begin
    LeftMouseClickInGame(x, y);
  end
  else 
  begin
    RightMouseClickInGame(x, y);
    //show collor
    //and print GetClosestColor
  end;      
end;




procedure MouseDown(x, y, mb: integer);
begin
  //case gamestate
  case gamestate of
    0:
      MouseDownStart();
    1:
      MouseDownInGame(x, y, mb);
    2:
      MouseDownVictory();
    3:
      MouseDowncColorTip();
    end
end;

procedure FillColorArrays();
begin
  var clrArray := ReadAllLines(clrFileName);
  clrNames := new string[clrArray.Length -1];
  clrRGBvalues := new integer[clrArray.Length - 1, 3];
  for var i := 1 to clrArray.Length - 1 do
  begin
    var s := clrArray[i].Split(',');
    clrNames[i - 1] := s[3]; //name
    clrRGBvalues[i - 1, 0] := s[0].ToInteger;
    clrRGBvalues[i - 1, 1] := s[1].ToInteger;
    clrRGBvalues[i - 1, 2] := s[2].ToInteger;//rgb values
  end;
end;

begin
  SetWindowSize(cs * w, cs * h);
  FillColorArrays;
    
  LoadLevel(1);
  DrawGrid();
  
  OnMouseDown := MouseDown;
end.