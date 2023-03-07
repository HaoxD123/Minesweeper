import de.bezier.guido.*;

public final static int NUM_ROWS = 20;
public final static int NUM_COLS = 20;
public final static int NUM_MINES = (int)(Math.random()*15) + NUM_ROWS*NUM_COLS/10;

//2d array of minesweeper buttons
private MSButton[][] buttons = new MSButton[NUM_ROWS][NUM_COLS]; 

//ArrayList of just the minesweeper buttons that are mined
private ArrayList <MSButton> mines = new ArrayList <MSButton>(); 

public boolean isLost;

void setup ()
{
  size(400, 400);
  textAlign(CENTER, CENTER);
  textSize(20);

  // make the manager
  Interactive.make( this );

  //your code to initialize buttons goes here
  //assign an oject to the whole 2d array
  for (int i = 0; i < NUM_ROWS; i += 1) {
    for (int j = 0; j < NUM_COLS; j+= 1) {
      buttons[i][j] = new MSButton(i, j);
    }
  }
  setMines();
}

public void draw() {
}

public void setMines()
{
  //your code
  //randomly generate mine and avoid repetition
  int row;
  int col;
  for (int i = 0; i < NUM_MINES; i += 1) {
    row = (int)(Math.random()*(NUM_ROWS));
    col = (int)(Math.random()*(NUM_COLS));
    if (!mines.contains(buttons[row][col]))
      mines.add(buttons[row][col]);
    else
      i -= 1;
  }
}

public boolean isWon()
{
  //your code here
  float sum = 0;
  for (int i = 0; i < NUM_ROWS; i += 1) {
    for (int j = 0; j < NUM_COLS; j += 1) {
      if (buttons[i][j].clicked)
        sum += 1;
    }
  }
  if (sum == NUM_ROWS*NUM_COLS - mines.size())
    return true;

  return false;
}

public void displayMessage()
{
  //your code here
 fill(255);

  if (isWon()) {
    displayMine();
    textSize(40);
    text("You Win!", width/2, height/2);
  }
  if (isLost) {
    displayMine();
    textSize(40);
    text("You Lost", width/2, height/2);
    
  }
  textSize(20);
}

public boolean isValid(int row, int col)
{
  //your code here
  if (row >= 0 && row <= NUM_ROWS - 1 && col >= 0 && col <= NUM_COLS - 1)
    return true;
  else
    return false;
}

public int countMines(int row, int col)
{
  int numMines = 0;
  //your code here
  for (int i = -1; i <= 1; i += 1) {
    for (int j = -1; j <= 1; j += 1) {
      if (isValid(row + i, col + j) && mines.contains(buttons[row + i][col + j]))
        numMines += 1;
    }
  }
  return numMines;
}

public void displayMine() {
  if (isLost == true) {
    for (int i = 0; i < NUM_ROWS; i += 1) {
      for (int j = 0; j < NUM_COLS; j += 1) {
        if (mines.contains(buttons[i][j]))
          buttons[i][j].clicked = true;
      }
    }
  }
}

public class MSButton
{
  private int myRow, myCol;
  private float x, y, width, height;
  private boolean clicked, flagged, doubleclicked;
  private String myLabel;

  public MSButton ( int row, int col )
  {
    width = 400/NUM_COLS;
    height = 400/NUM_ROWS;
    myRow = row;
    myCol = col;
    x = myCol*width;
    y = myRow*height;
    myLabel = "";
    flagged = clicked = doubleclicked = false;
    Interactive.add( this ); // register it with the manager
  }

  // called by manager
  public void mousePressed ()
  { 
    //responses to right click
    if (mouseButton == RIGHT && clicked == false) {
      if (flagged == false) {
        flagged = true;
      } else if (flagged == true ) {
        flagged = false;
      }
    } else {
      //responses to left click
      if (clicked == true)
        doubleclicked = true;
      if (flagged == false)
        clicked = true;

      //safe but with other mines around
      if (countMines(myRow, myCol) > 0  && flagged == false && !mines.contains(this)) {
        setLabel(countMines(myRow, myCol));
      }

      //mine detected
      else if (mines.contains(this)) {
        isLost = true;
      } 

      //safe but without other mines around, so clear out nearby area
      else if (!mines.contains(buttons[myRow][myCol]) && doubleclicked == false) {
        for (int i = 1; i >= -1; i -= 1) {
          for (int j = 1; j >= -1; j -= 1) {
            if (isValid(myRow + i, myCol + j) && 
              mines.contains(buttons[myRow + i][myCol + j]) == false && 
              buttons[myRow + i][myCol + j].clicked == false &&
              buttons[myRow + i][myCol + j].flagged == false)
              buttons[myRow + i][myCol + j].mousePressed();
          }
        }
      }
    }
  }

  public void draw ()
  {    
    if (flagged)
      fill(255, 0, 0);
    else if (clicked && mines.contains(this) )
      fill(0);
    else if (clicked)
      fill(255);
    else
      fill(255, 182, 193);

    //If conditions met, repress button to clear out field around
    if (flagged == false && !mines.contains(this) && doubleclicked == true) {
      int count = 0;
      for (int i = 1; i >= -1; i -= 1) {
        for (int j = 1; j >= -1; j -= 1) { 
          if (isValid(myRow + i, myCol + j) &&
            buttons[myRow + i][myCol + j].flagged == true && 
            mines.contains(buttons[myRow + i][myCol + j]))
            count += 1;
        }
      }
      if (parseInt(myLabel) == count) {
        for (int i = 1; i >= -1; i -= 1) {
          for (int j = 1; j >= -1; j -= 1) {
            if (isValid(myRow + i, myCol + j) && 
              mines.contains(buttons[myRow + i][myCol + j]) == false && 
              buttons[myRow + i][myCol + j].clicked == false &&
              buttons[myRow + i][myCol + j].flagged == false &&
              mouseButton != RIGHT)
              buttons[myRow + i][myCol + j].mousePressed();
          }
        }
      } else {
        count = 0;
        for (int i = 1; i >= -1; i -= 1) {
          for (int j = 1; j >= -1; j -= 1) {
            if (buttons[myRow + i][myCol + j].flagged &&
              !mines.contains(buttons[myRow + i][myCol + j]))
              count += 1;
          }
        }
        if (count > 0) {
          isLost = true;
        } else
          isLost = false;
      }
    }
    rect(x, y, width, height);
    fill(0);
    text(myLabel, x+width/2, y+height/2);

    //test winning or losing
    displayMessage();
  }
  public void setLabel(String newLabel)
  {
    myLabel = newLabel;
  }
  public void setLabel(int newLabel)
  {
    myLabel = ""+ newLabel;
  }
}
