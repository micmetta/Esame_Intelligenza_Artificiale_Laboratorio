import javax.swing.JFrame; //imports JFrame library
import javax.swing.JButton; //imports JButton library
import java.awt.GridLayout; //imports GridLayout library
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;


import java.io.*;


public class BattleMap {

	static int rows=10, cols=10;


	JFrame frame=new JFrame(); //creates frame
	JButton[][] grid; //names the grid of buttons


        
        static Cell [][] matrix;

        ImageIcon water = new ImageIcon("water.png");



	public BattleMap(){//constructor

	      buttonMatrix(rows, cols);
		
	   

	      frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
    
	      frame.pack(); //sets appropriate size for frame
	      frame.setVisible(true); //makes frame visible
		
       }

	public void buttonMatrix(int width, int length){ 
		frame.setLayout(new BorderLayout());

                setupMatrix();


		Container c = frame.getContentPane();
		c.setLayout(new BorderLayout());


		JPanel panGrid = new JPanel();
		c.add(panGrid, BorderLayout.NORTH);


		panGrid.setLayout(new GridLayout(width,length)); //set layout

                //frame.setLocationRelativeTo(null);
	        //frame.setSize(1600,1080);

		grid=new JButton[width][length]; //allocate the size of grid
                int counter = 0;
		for(int x=0; x<width; x++){
		 	for(int y=0; y<length; y++){

				grid[x][y]=new JButton("B"+counter); //creates new button"("+x+","+y+")"
				grid[x][y].setHideActionText(true);
				grid[x][y].setFont(new Font("Arial", Font.PLAIN, 1));
				counter++;
				if (matrix[x][y].isWater())
                                    grid[x][y].setIcon(water);
				grid[x][y].setPreferredSize(new Dimension(100, 100));	  
				panGrid.add(grid[x][y]); //adds button to grid
                               
                                grid[x][y].addActionListener(new ActionListener()
					{
   
					  public void actionPerformed(ActionEvent e)
					  {
						String command = e.getActionCommand();
						String cellS = command.substring(1);
						int numButt = Integer.parseInt(cellS);
						int row = numButt / width;
						int col = numButt % width;

						Object[] possibilities = {"water", "sub", "middle",  "top", "bot", "left", "right"};
						JCheckBox checkbox = new JCheckBox("Noto all'inizio?");
						Object[] params = {frame, checkbox};
	
						String s = (String)JOptionPane.showInputDialog(
								    frame,
								    "Selezionare l'opzione",
								    "Plan the battle",
								    JOptionPane.PLAIN_MESSAGE,
								    null,
								    possibilities, 
								    "water");


						JOptionPane.showConfirmDialog(frame, checkbox, "", JOptionPane.PLAIN_MESSAGE);

					

						
						if ((s != null) && (s.length() > 0)) {
						   matrix[row][col].setContent(s);
						   matrix[row][col].setInitial(checkbox.isSelected());
						   updateButton(row, col, s);
						}

					  }
					});
			}
		}


	   JPanel newPan = new JPanel();
	   JButton save = new JButton("Save");
	   newPan.setLayout(new BorderLayout());
	   newPan.add(save);

	   save.addActionListener(new ActionListener(){
			public void actionPerformed(ActionEvent e) {
               System.out.println("SAVING...");
				saveMap();
			}});
	   c.add(newPan);
	}



        private void updateButton(int x, int y, String s){
	        ImageIcon ico = new ImageIcon(s+".png");
		grid[x][y].setIcon(ico);
		if (matrix[x][y].isInitial()){
			grid[x][y].setBackground(Color.RED);
			grid[x][y].setOpaque(true);
		}
		else {
			grid[x][y].setBackground(null);
			grid[x][y].setOpaque(false);
		}
        }

	private void setupMatrix (){
		matrix = new Cell[rows][cols];
		for (int i=0; i< rows; i++)
			for (int j=0; j<cols; j++)
				matrix[i][j]=new Cell();
	}


	private void saveMap(){

		try{
		      File file = new File("mapEnvironment.clp");

		      file.createNewFile();
		      FileWriter writer = new FileWriter(file);

		      writer.write("(deffacts battle-field\n"); 

		      for (int x=0; x < rows; x++)
			for (int y=0; y< cols; y++){
	
				writer.write("(cell (x " + x + ") (y " + y+ ") (content " + matrix[x][y].getContentSimple() + ") (status none))\n"); 

			}
		      int counter = 0;

		      for (int x=0; x < rows; x++)
			for (int y=0; y< cols; y++){
	
				if (matrix[x][y].isSub())
				writer.write("(boat-hor (name sub"+ ++counter +") (x "+ x +") (ys "+  y + ") (size 1) (status safe))\n"); 

				if (matrix[x][y].isLeft()){
					int z = findHorBoat(x, y);
					int k = z;
					writer.write("(boat-hor (name nav"+ ++counter +") (x "+ x +") (ys ");
					String safes = "";
					for (k=y; k<=z; k++){
						writer.write(k + " ");
						safes += "safe ";
					}

		                        writer.write( ") (size " + (z-y + 1) + ") (status "+safes+"))\n");
				}


				if (matrix[x][y].isTop()){
					int z = findVerBoat(x, y);
					int k = z;
					writer.write("(boat-ver (name nav"+ ++counter +") (y "+ y +") (xs ");
					String safes = "";
					for (k=x; k<=z; k++){
						writer.write(k + " ");
						safes += "safe ";
					}

		                        writer.write( ") (size " + (z-x + 1) + ") (status "+safes+"))\n");
				}
				

			}


		for (int x=0; x < rows; x ++)
			for (int y=0; y< cols; y++){
			if (matrix[x][y].isInitial()){
			     writer.write("(k-cell (x "+ x + ") " + "(y " + y + ") (content " + matrix[x][y].getContent() + "))\n");
			}

		}

		
		for (int x=0; x < rows; x ++){
		   int numboat =0;
		   for (int y=0; y< cols; y++)
			if (!matrix[x][y].isWater())
			    numboat++;
			
	            writer.write("(k-per-row (row "+ x + ") " + "(num " + numboat  + "))\n");
		}

		for (int y=0; y< cols; y++){
		   int numboat =0;
		   for (int x=0; x < rows; x ++)
			if (!matrix[x][y].isWater())
			    numboat++;
			
	          writer.write("(k-per-col (col "+ y + ") " + "(num " + numboat + "))\n");
		}


			
                       
       		      writer.write(")\n"); 

		      writer.flush();
		      writer.close();


		    
		}catch(Exception e){
			e.printStackTrace();
		}
        }

	private int findHorBoat(int x, int y){
		int k;
		for (k = y; k < cols; k++)
			if (matrix[x][k].isRight()) return k;
		return k; //nel caso in cui manchi il lato destro della nave
	}

	private int findVerBoat(int x, int y){
		int k;
		for (k = x; k < rows; k++)
			if (matrix[k][y].isBot()) return k;
		return k; //nel caso in cui manchi il lato destro della nave
	}


	public static void main(String[] args) {

		

   	
             BattleMap window = new BattleMap();	


	}



    class Cell {

 	String content;
	boolean initial;

        Cell(){
		content = "water";
		initial = false;
	}
       
        boolean isWater(){
		return content.equals("water");
	}

	void setContent(String s){
		content = s;
	}
	
	void setInitial(boolean val){
		initial = val;
	}

	boolean isInitial(){
		return initial;
	}
	
	String getContentSimple(){
		if (isWater()) return content;
		return "boat";
	}

	String getContent(){
		return content;
	}

	boolean isSub(){
		return content.equals("sub");
	}

	boolean isLeft(){
		return content.equals("left");
	}

	boolean isRight(){
		return content.equals("right");
	}

	boolean isTop(){
		return content.equals("top");
	}

	boolean isBot(){
		return content.equals("bot");
	}

     }
}


