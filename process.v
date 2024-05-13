`timescale 1ns / 1ps

module process(
	input clk,				// clock 
	input [23:0] in_pix,	// valoarea pixelului de pe pozitia [in_row, in_col] din imaginea de intrare (R 23:16; G 15:8; B 7:0)
	output reg [5:0] row, col, 	// selecteaza un rand si o coloana din imagine
	output reg out_we, 			// activeaza scrierea pentru imaginea de iesire (write enable)
	output reg [23:0] out_pix,	// valoarea pixelului care va fi scrisa in imaginea de iesire pe pozitia [out_row, out_col] (R 23:16; G 15:8; B 7:0)
	output reg mirror_done,		// semnaleaza terminarea actiunii de oglindire (activ pe 1)
	output reg gray_done,		// semnaleaza terminarea actiunii de transformare in grayscale (activ pe 1)
	output reg filter_done);	// semnaleaza terminarea actiunii de aplicare a filtrului de sharpness (activ pe 1)
	
	reg [7:0] r, g, b;
	reg [5:0] state, next_state;
	reg [5:0] next_col, next_row; 
	reg [23:0] aux, aux1;
	reg [7:0] ma = 0, min = 0, max = 0; 

	//reg [7:0] matrice [2:0][2:0] = { {-1, -1, -1},
                                  //{-1, 9, -1},
                                  //{-1, -1, -1} };
	
	//stari automat
	reg [3:0] INCEPUT = 0;
	reg [3:0] MIRROR = 1;
	reg [3:0] SALVEZ_PIXEL = 2;
	reg [3:0] INTERSCHIMB_SI_SALVEZ = 3;
	reg [3:0] SALVEZ = 4;
	reg [3:0] START = 5;
	reg [3:0] GRAYSCALE = 6;
	reg [3:0] SALVEZ_PIXEL_CULORI = 7;
	reg [3:0] SALVEZ_IN_G = 8;
	reg [3:0] START_FINAL = 9;
	reg [3:0] FILTER = 10;
	
	
	always @(posedge clk)begin 
		state <= next_state;
		row <= next_row;
		col <= next_col;
	end
	
	
	always @(*)begin
		case(state)
		  
		  //initiere
		  INCEPUT:begin
		  
				next_row = 0;
				next_col = 0;
				out_we = 0;
				mirror_done = 0;
				gray_done = 0;
				filter_done = 0;
				next_state = MIRROR;
				
			end
		  
		  //fac mirror-ul pe coloane si parcurc doar jumatate din randuri
		  MIRROR:begin
		  
		  if (col <= 63)begin
			  if (row < 32)begin
			  
					out_we = 0;
					next_state = SALVEZ_PIXEL;
					
			  end
			  else begin
	
					next_row = 0;
					next_col = col + 1;
					next_state = MIRROR;
					
			  end
		  end
		  if( col > 62 && row == 32) begin
		  
			  mirror_done = 1;
			  next_state = START;
			  
		  end
		  end
		  
		  //salvez pixel de pe randul row si merg pe randul 63 - randul curent
		  SALVEZ_PIXEL:begin
				
				aux = in_pix;
				next_row = 63 - row;
				next_state = INTERSCHIMB_SI_SALVEZ;
				
			end
			
			//salvez pixelul de pe randul actual, initializez scrierea si scriu pixelul 
			INTERSCHIMB_SI_SALVEZ:begin
			
				out_pix = aux;
				aux1 = in_pix;
				next_row = 63 - row;
				out_we = 1;
			   next_state = SALVEZ;
				
			end 
			
			//salvez si celalalt pixel pe pozitie, maresc randul si revin la starea MIRROR
			SALVEZ:begin
			
				out_pix = aux1;
				out_we = 1;
				next_state = MIRROR;
				next_row = row + 1;
				
			end
			
			//reinitializez cu 0 randul, coloana, si scrierea
			START:begin
			
				out_we = 0;
				next_row = 0;
				next_col = 0;
				next_state = GRAYSCALE;
				
			end
				
			//parcurc matricea in intregime si trec in starea urmatoare
			GRAYSCALE:begin
			
				if (col <= 63)begin
					if (row < 63)begin
						out_we = 0;
						next_state = SALVEZ_PIXEL_CULORI;
					end
			   else begin
					next_row = 0;
					next_col = col + 1;
					next_state = GRAYSCALE;
			   end
			   end
				if( col > 62 && row > 62) begin
					gray_done = 1;
					next_state = START_FINAL;
					
				end
			end
		  
		  //salvez pixelii pe culori, fac min si max si media
		  SALVEZ_PIXEL_CULORI: begin
		  
				r = in_pix[23:16];
            g = in_pix[15:8];
            b = in_pix[7:0];
				
				min = (r < g) ? r : g;
				min = (min < b) ? min : b;

				max = (r > g) ? r : g;
				max = (max > b) ? max : b;
				
				ma = (min + max) / 2;
				
				next_state = SALVEZ_IN_G;
				
			end
			
			//initializez scrierea si salvez noile valori r,g si b, merg pe urmatorul rand si ma intorc in GRAYSCALE
			SALVEZ_IN_G:begin
				
				r = 0;
				g = ma;
				b = 0;
				
				out_pix = { r, g, b};
				
				out_we = 1;
				next_row = row + 1;
				next_state = GRAYSCALE;
				
			end
			
			START_FINAL:begin
			
				out_we = 0;
				next_row = 0;
				next_col = 0;
				next_state = FILTER;
			
			end
			
			FILTER:begin
				filter_done = 1;
						
						
			end
			
			
			default: next_state = INCEPUT;
		endcase
	end
	
   
	endmodule
