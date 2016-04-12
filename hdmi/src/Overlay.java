
/*
* To change this license header, choose License Headers in Project Properties.
* To change this template file, choose Tools | Templates
* and open the template in the editor.
*/
package drawingoverlay;
import java.awt.Color;
import java.awt.Font;
import java.awt.FontMetrics;
import java.awt.Graphics;
import java.awt.Window;
import javax.swing.*;
/**
*
* @author kevin
*/
// Resolution : 1600 x 900
public class Kevin_code_code {
	
	public static int x_to_x(int x_want){
		
		int x_true = x_want*1366/1600;
		return x_true;
	}
	public static int y_to_y(int y_want){
		int y_true = y_want*768/900;
		return y_true;
	}
	
	public static void main(String[] args){
		Window w=new Window(null)
		{
			@Override
			public void paint(Graphics g)
				{
					final Font font = getFont().deriveFont(48f);
					g.setFont(font);
					g.setColor(Color.RED);
					
					g.drawRect(0, 0, x_to_x(1920), y_to_y(1080));
					
					int h_sub = 32;
					int w_sub = 32;
					int dd = 8;
					int I0 = 199;
					int J0 = 129;
					int I1 = I0 + 19*w_sub;
					int J1 = J0 + 19*h_sub;
					int left = I0-3;
					int right = I1 + 3;
					int top = J0 - 3;
					int bottom = J1 + 3;
					
					//g.drawRect(I0, J0, I1, J1);
					for (int i = I0 + (int)(w_sub/2); i<=I1; i = i+w_sub){
						for (int j= J0 + (int)(h_sub/2); j<= J1; j = j+ h_sub){
							g.drawLine(x_to_x(I0), y_to_y(j), x_to_x(I1), y_to_y(j));
							g.drawLine(x_to_x(i), y_to_y(J0), x_to_x(i), y_to_y(J1));
						}
					}
					/*g.setColor(Color.BLUE);
					
					g.drawLine(x_to_x(left-dd), y_to_y(top-dd), x_to_x(left-dd), y_to_y(bottom+dd));
					g.drawLine(x_to_x(left-dd), y_to_y(top-dd), x_to_x(right+dd), y_to_y(top-dd));
					g.drawLine(x_to_x(right+dd), y_to_y(bottom+dd), x_to_x(left-dd), y_to_y(bottom+dd));
					g.drawLine(x_to_x(right+dd), y_to_y(bottom+dd), x_to_x(right+dd), y_to_y(top-dd));
					
					g.drawLine(x_to_x(left+dd), y_to_y(top+dd), x_to_x(left+dd), y_to_y(bottom-dd));
					g.drawLine(x_to_x(left+dd), y_to_y(top+dd), x_to_x(right-dd), y_to_y(top+dd));
					g.drawLine(x_to_x(right-dd), y_to_y(bottom-dd), x_to_x(left+dd), y_to_y(bottom-dd));
					g.drawLine(x_to_x(right-dd), y_to_y(bottom-dd), x_to_x(right-dd), y_to_y(top+dd));
					
					g.setColor(Color.GREEN);
					
					g.drawLine(x_to_x(left), y_to_y(top), x_to_x(left), y_to_y(bottom));
					g.drawLine(x_to_x(left), y_to_y(top), x_to_x(right), y_to_y(top));
					g.drawLine(x_to_x(right), y_to_y(bottom), x_to_x(left), y_to_y(bottom));
					g.drawLine(x_to_x(right), y_to_y(bottom), x_to_x(right), y_to_y(top));
					*/
					
					
				}
			@Override
			public void update(Graphics g)
			{
				paint(g);
			}
		};
		w.setAlwaysOnTop(true);
		w.setBounds(w.getGraphicsConfiguration().getBounds());
		w.setBackground(new Color(0, true));
		w.setVisible(true);
	}
}