class Textbox
{
  PVector pos,size,textPos;
  String[] text;
  String title;
  boolean selected;
  int textLimit,opacity,textPointer;
  
  Textbox(String _title, PVector _pos, PVector _size, int _textLimit, int _textLines)
  {
    title = _title;
    selected = false;
    opacity = 50;
    pos = _pos;
    size = _size;
    textPos = new PVector(10,10);
    textLimit = _textLimit;
    textPointer = 0;
    text = new String[_textLines];
    for(int i=0; i<text.length; i++)
    {
      text[i]="";
    }
  }
  
  void display()
  {
    pushMatrix();
      stroke(0);
      translate(pos.x,pos.y);
      textAlign(LEFT,TOP);
      rectMode(CENTER);
      fill(0);
      textSize(16);
      text(title,-size.x/2,-20-size.y/2);
      textLeading(5);
      textSize(12);
      fill(0,opacity);
      rect(0,0,size.x,size.y);
      fill(0);
      for(int i=0; i<text.length; i++)
      {
        text(text[i],10-size.x/2,i*15-size.y/2);
      }
      line(textWidth(text[textPointer])+10-size.x/2,textPointer*15-size.y/2,textWidth(text[textPointer])+10-size.x/2,textPointer*15+10-size.y/2);
    popMatrix();
  }
  
  void typed()
  {
    if(selected)
    {
      if(keyPressed)
      {
        if(key == CODED)
        {
          
        }
        else if(key != CODED)
        {
          if(key ==BACKSPACE || key==DELETE)
          {
            if(text[textPointer].length()==0 && textPointer>0)
            {
              textPointer-=1;
            }
            if(text[textPointer].length()>0)
            {
              text[textPointer]=text[textPointer].substring(0,text[textPointer].length()-1);
            }
          }
          else if(key==ENTER || key==RETURN)
          {
            if(textPointer<text.length-1)
            {
              textPointer++;
            }
          }
          else
          {
            checkCarat();
            text[textPointer]+=key;
          }
        }
      }
    }
  }
  
  void checkSelected()
  {
    if(mouseX>pos.x-size.x/2
    && mouseX<pos.x+size.x/2
    && mouseY>pos.y-size.y/2
    && mouseY<pos.y+size.y/2)
    {
      selected = true;
      opacity=0;
    }
    else
    {
      selected = false;
      opacity=50;
    }
  }
  
  void checkCarat()
  {
    if(text[textPointer].length()>=textLimit && textPointer<text.length-1)
    {
      textPointer++;
    }
  }
  
  String getFinalText()
  {
    String finalText = "";
    for(int i=0; i<text.length; i++)
    {
      finalText+=text[i];
    }
    return finalText;
  }
}
