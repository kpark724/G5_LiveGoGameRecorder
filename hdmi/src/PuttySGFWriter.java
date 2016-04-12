/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package puttysgfwriter;

import java.io.IOException;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.util.StringTokenizer;

/**
 *
 * @author kevin
 */
public class PuttySGFWriter {

    public static void main(String[] args) {
        // The name of the file to open.
        String fileName = "temp.txt";
        String sgfFileName = "testing.sgf";
        String tmp;
        int color;
        int x;
        int y;

        // This will reference one line at a time
        String line = null;

        try {
            // FileReader reads text files in the default encoding.
            FileReader fileReader = 
                new FileReader(fileName);

            // Always wrap FileReader in BufferedReader.
            BufferedReader bufferedReader = 
                new BufferedReader(fileReader);

            // Assume default encoding
            FileWriter fileWriter = new FileWriter(sgfFileName);
            
            // Always wrap FileWriter into BufferedWriter
            BufferedWriter bufferedWriter = new BufferedWriter(fileWriter);
            
            
            // Make sure SGF file is for Go and size of the board is 19x19
            bufferedWriter.write("(;GM[1]SZ[19]");
            bufferedWriter.newLine();
            
            // each line contains a move
            while((line = bufferedReader.readLine()) != null) {
                StringTokenizer Tok = new StringTokenizer(line);
                color = Integer.parseInt((String) Tok.nextElement());
                x = Integer.parseInt((String) Tok.nextElement());
                y = Integer.parseInt((String) Tok.nextElement());
                
                tmp = "";
                if (color == 1){
                    tmp += ";W[";
                } else if (color == 2){
                    tmp += ";B[";
                } else if (color == 0){
                    break;
                }
                
                tmp += (char)(x + 'a');
                tmp += (char)(y + 'a');
                tmp += "]";
                
                bufferedWriter.write(tmp);
                bufferedWriter.newLine();
                
                // System.out.println(tmp);
            }   
            
            bufferedWriter.write(")");
            bufferedWriter.newLine();
            
            bufferedWriter.close();
            // Always close files.
            bufferedReader.close();         
        }
        catch(FileNotFoundException ex) {
            System.out.println(
                "Unable to open file '" + 
                fileName + "'");                
        }
        catch(IOException ex) {
            System.out.println(
                "Error reading file '" 
                + fileName + "'");                  
            // Or we could just do this: 
            // ex.printStackTrace();
        }
        catch (Exception ex){
            System.out.println("Error: unknown exception type");
        }
    }
    
    
}
