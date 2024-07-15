/**
* Name: guacamolerecipev2
* Based on the internal empty template. 
* Author: vtwoptwo
* Tags: 
*/


model guacamolerecipev2


global {
	
	point cam_up_vector;
	point cam_look_pos;
	point cam_position;
	point target_location;
    geometry shape <- rectangle(137.5, 68.5); //, by  each square in the floor is 50 cm and so we have a predefined area of 7 by 4 squares
    geometry shape2 <- rectangle(124, 62); //137.5, by 68.5 each square in the floor is 50 cm and so we have a predefined area of 7 by 4 squares
    point correction <- {71.20521068572998,-106.8634033203125,0}; ///['71.20521068572998','-106.8634033203125']
	point offset <- {0,0,0};
    int i<-0;
    bool DrawExtendedInfo <- true;
    list<geometry> arena_keystone <- [{0.06990871268885124,0.3834149498493714,0.0},{0.0693840701326465,1.050735957897178,0.0},{0.784731733720296,1.1383421587236286,0.0},{0.8101683593216661,0.34381552390748216,0.0}];
   // kitchen [{0.07832623134128786,0.2369052063659174,0.0},{-0.006373597739283254,1.2593646670452996,0.0},{0.9292324705871248,1.134647468552529,0.0},{0.873299749214941,0.21162772590803702,0.0}];
    // [{0.07832623134128786,0.23560979010275052,0.0},{0.09112932665144124,1.0730290543422345,0.0},{0.7812244342817803,1.0479524866586418,0.0},{0.871195369551832,0.21421855843437076,0.0}];
    //[{0.08884812965683364,0.21490583313574307,0.0},{0.004148300576262531,1.2166627558008456,0.0},{0.920814951934688,1.1462962822519287,0.0},{0.8697924497764258,0.22068854498656065,0.0}];
    int port <- 9876;
    string url <- "10.205.3.36";
    int number_of_agents <- 10; // New variable to specify the number of agents
    int first_agent_port <- 9876; // Starting port for the first agent
	int i_ <- 0;
	int proximity_graph_distance;
	bool draw_connections<- true;
	graph<simple_agent, simple_agent> proximity_graph;
	
	// RECIPE RELATED VARIABLES
	
	// recipe name
	
	//ingredient squares
	bool show_recipe_name <- false;
	
	
	// UDP  steps 
	int show_step <- 0;
    float increment <- 5.0;
	int first_step_port <- 4242;
	point base_loc <- {87.5,55.0,0.01};
	bool draw_recipes <- true;
	int number_of_steps <- 5;
	float size_of_quantity;
	
	//UDP recipe ingredients
	int number_of_ingredients <- 4;
	int i_ingredient <- 0;
	int first_ingredient_port <- 666;
	point base_loc_ingredients <- {120,58.0,0.01};
	float increment_ingredients<- -10.0;
	
	
	// UDP llm agent
	int number_of_llm_agents <- 1;
	int l <- 0;
	int first_llm_port <- 1999;
	
	

	// --- visual
	file ingredients_border <- file('./../static/rectircle.png');
	bool detecting_ingredients <- false;
	
	//visuals for loading / thinking effect
	bool last<-true;
	file loading <- file('./../static/loading_icon.gif');
	bool loading_ingredients<-false;
	file message_loading_ingredients <- file('./../static/loading_ingredients.png');
	bool loading_recipe<-false;
	file message_loading_recipe <- file('./../static/loading_recipe.png');
	
	//visuals for roating through recipe effect
	bool give_visual_instructions_for_rotating <- false;
	

	//  COLORS
	rgb green_dark_mild <- rgb(3, 152, 85, 225);
	rgb green_dark <- rgb(48, 107, 58, 255);
	rgb green_highlight_light <- rgb(34,197,94,255);
	rgb text_grey <- rgb(102,102,102,255);
	rgb grey_light <- rgb(217,217,217,255);

		
	bool show_border<- false;

    init {
    	
    	create llm_agent number: number_of_llm_agents{
    		do connect to: "localhost" protocol: "udp_server" port: first_llm_port +l;
    		l <- l +1;
    	}
    	
    	
		create simple_agent number:number_of_agents {
		   do connect to: "localhost" protocol: "udp_server" port: first_agent_port+i;
		   i<-i+1;
		   self.name <- i;
		   }
		   
	
		
		
		create recipe_step number:number_of_steps{
		  do connect to: "localhost" protocol: "udp_server" port: first_step_port+i_;
		  i_<-i_+1;
		  self.name <- i_;
		 
		  base_loc <- {base_loc.x - increment, base_loc.y, base_loc.z};
		  self.location <-  base_loc;}
		  
		  
		  
		create ingredient number:number_of_ingredients{
		  do connect to: "localhost" protocol: "udp_server" port: first_ingredient_port+i_ingredient;
		  i_ingredient<-i_ingredient+1;
		  base_loc_ingredients <- {base_loc_ingredients.x, base_loc_ingredients.y+
		  	increment_ingredients, base_loc_ingredients.z
		  };
		  self.location <-  base_loc_ingredients;
}

}


reflex updateProximityGraph when: draw_connections {

		proximity_graph <- graph<simple_agent, simple_agent>(list(simple_agent) as_intersection_graph(proximity_graph_distance));
		
	}
}

species recipe_step skills: [network] {
	init {
		write "Agent Creation";
		
	}
	
	bool received_description;
    string recipe_step_description;

    string RECIPE_NAME <- "Recipe";
   	agent simple_agent;
   	float quant;
    
    reflex collect_messages when: has_more_message() {
        loop while: has_more_message() {
            message msg <- fetch_message();
           	list<string> recipe_steps <- msg.contents split_with(",");
           	//write recipe_steps;
         	list parsed_data <- msg.contents;
         	self.name <- recipe_steps[0];
         	RECIPE_NAME <- recipe_steps[5];
    		string v <- recipe_steps[4];
    		write "recipe_steps";
    		write v;
         	list<string> temp_var_size <- v regex_matches("[-+]?\\d*\\.?\\d+");
         	quant <- float(temp_var_size[0]);
         	write quant;
         	
         	
    
   
         	recipe_step_description <- recipe_steps[1];
         	
         	received_description <-true;
  				if (int(recipe_steps[3])=1){
         		last <- true;	
         		loading_recipe<-false;
         		give_visual_instructions_for_rotating <- true;
         	}
         	else{
         		last <- false;
         		loading_recipe<-true;
         		
         	}
         	//write "initialized:";
         	//write self.name;
        
         	}
         
        }
 
    aspect default {

    	if (received_description=true){
    		 if !(show_step=int(self.name)){
		   		draw circle(2) at: self.location  color: #white border: green_dark_mild;
		   		
		   }
    		if (int(self.name) = 1){
    			   	draw RECIPE_NAME color: green_dark  at: {78,60,0.01} font:font("OpenSans", 40 , #bold) rotate: 180;
    				//draw loading at: self.location + {-14,1.5,0} size: {5,5};
    		
    	}

    	 if (show_step=int(self.name)){
		   		draw circle(2) at: self.location  color: green_dark_mild border: green_dark_mild;
	   		  // draw the description steps
				
				if (float(quant)>0){
					
				point circle_point <- {80.5, 35, 0.01};
				draw circle(float(quant)) at: circle_point color: #white border: green_dark_mild ;
				draw "Confusing quantities? Put the cut food to fill the circle." color: green_dark at: {circle_point.x - 10, circle_point.y, 0.01} font:font("OpenSans", 20 , #bold) rotate: 180;
				}
			    point step_description_location<-{80.5, 48,0.01}; //{55,14.5,0.01};
    			list<string> description_steps <- recipe_step_description split_with(";");
		    	loop i from: 0 to: length(description_steps) step: 1 {
		    		draw description_steps[i] color: green_dark  at: step_description_location  font:font("OpenSans", 20 , #bold) rotate: 180;
		    		step_description_location <- {step_description_location.x, step_description_location.y - 3,step_description_location.z};
		    		//write description_steps[i];
				}
				
				
					


		   		} 
		   		
		   		
		   }
	
	
			 
		}
	
}


species llm_agent skills: [network] {
	
	init {
		write "Initialized LLM Agent";
	}

    reflex collect_messages when: has_more_message() {
        loop while: has_more_message() {
            message msg <- fetch_message();
           	write msg.contents;
           	
           	
        }
        
        }

    aspect default {

    	
    	//write message;
    	
			 
		}
	
}

species ingredient skills: [network] {
	init {
		write "Ingredient Detection";
	}
	bool received_ingredient<- false;
	string emoji;
    reflex collect_messages when: has_more_message() {
        loop while: has_more_message() {
            message msg <- fetch_message();
           	list<string> ingredients <- msg.contents split_with(",");
           	detecting_ingredients <- true;
         	self.name <- ingredients[0];
         	//emoji <- image_file("https://img.freepik.com/free-psd/photo-open-avocado-isolated-transparent-background_125540-5151.jpg", "jpg");
         	draw loading at: {6,28,0} size: {5,8};
         	emoji <- ingredients[1];
         	//write ingredients;
         	received_ingredient <- true;
         	         	
         	if (int(ingredients[2])=1){
         		last <- true;	
         		loading_ingredients<-false;
         	}
         	else{
         		last <- false;
         		loading_ingredients<-true;
         	}
         	//write "initialized:";
         	//write self.name;
         	}
        }

    aspect default {
//    	string ingredients_title <- "";
    	
//    	if (detecting_ingredients=true){
//    		draw ingredients_title at: {5.0,7.0,0.01} color: green_dark font:font("OpenSans", 20 , #bold) rotate: 180;
//			
//		}
		if (received_ingredient=true){
			draw ingredients_border at: self.location size: {20,9} rotate:180;
			//write emoji;
			//draw emoji at: {50 , 50, self.location.z};
			draw self.name at: {self.location.x + 12.0, self.location.y +1, self.location.z} color: green_dark font:font("OpenSans", 20 , #bold) rotate: 180;
			
			

		}
    	
			 
		}
	
}


species simple_agent skills: [moving, network] {

	  
	init {
		self.location <- {-500, -500, 0};
	}
	float x <- 0.0;
	float y <- 0.0;
	float z <- 0.0;
	float rot;
	point target_location;
	
   
    reflex fetch when: has_more_message() {
    	
        loop while: has_more_message() {
        	
   
        		
        
	            message msg <- fetch_message();
	            list<string> coords <- msg.contents regex_matches("[-+]?\\d*\\.?\\d+");
	           
                target_location <- {float(coords[0]), float(coords[1]), 1};
                
                target_location <- target_location - correction;
                target_location <- {target_location.x, -target_location.y, 0};
                rot <- float(coords[2])*-100;
                self.location <- target_location + offset;

        }
        
    }
    
    // logic to iterate through the steps
    reflex update_show_steps {
    	
    	if (self.name = string(1)){
    		
    	
    	if self.location.x < 19 and self.location.y < 19 {
    		
		    if (rot >= -300 and rot < -180) {
			        show_step <- 1;
			    } else if (rot >= -180 and rot < -60) {
			        show_step <- 2;
			    } else if (rot >= -60 and rot < 60 and  rot != 0.0) {
			        show_step <- 3;
			    } else if (rot >= 60 and rot < 180) {
			        show_step <- 4;
			    } else if (rot >= 180 and rot <= 300) {
			        show_step <- 5;
			    }
			    
			    }
		    
		    
		    
    }
}


    aspect default {
        draw triangle(10) at: {target_location.x,target_location.y, 1}  color: #white rotate: rot ;
		}
		
   
 
 }
 
grid space cell_width:0.5 cell_height:0.5  { //137.5 68.5
    aspect dev {
    	if (show_border){
    		draw shape color: #white border: #green width: 1 rotate: 180;
    		
    	}
    	else
    	{
        draw shape color: #white border: #white width: 1;
        
        }
    }
}

experiment MainVisualize type: gui virtual: true {
	float minimum_cycle_duration<-0.01;
	parameter "Show Step" var: show_step <- 0 min: 0 max:number_of_steps;
	parameter "Show Grid" var: show_border <- false category: "Wanna see the grid?" ; 
    parameter "URL" var: url <- "10.205.3.9" among: ["10.205.3.55", "127.0.0.1","10.205.3.9", "10.205.3.82"] category: "Connection Variables";
    parameter "PORT" var: port <- 9876 among: [9876, 1234,53408] category: "Connection Variables";
    parameter "Number of Agents" var: number_of_agents <- 2 min:0 max:10 category: "Connection Variables";
    parameter "Proximity graph distance" var: proximity_graph_distance <- 50 category: "Connectivity Interaction" min: 1 max:150;
    parameter "Draw connections" var: draw_connections <- false enables:[proximity_graph];
    parameter "camera_pos" var: cam_position <- {60.2654,227.7376,221.0116}  category: "Camera";
    parameter "camera_look_pos" var: cam_look_pos <- {62.0,31.0,0.0} category: "Camera";
    parameter "camera_up_vector" var: cam_up_vector <- {0,0,1}  category: "Camera";
    parameter "offset " var: offset <- {8,130,0} category: "Offset";
    //camera 'default' location:  target: ;
     
    output {
        display objects_display type: opengl toolbar: false virtual: true {
           
            
            species recipe_step  position: {0, 0, 0.1} ;
            species simple_agent position: {0, 0, -2};
            species ingredient   position: {0, 0, 0.1};
            
            graphics "visual aid"{
            	//draw circle(2) at: {0,0,2};
            	if (give_visual_instructions_for_rotating=true){
            		draw "Rotate Me" at: {20,20,2} rotate: 180 color: green_dark font:font("OpenSans", 20 , #bold);
            		draw circle(0.1) at: {20,15,2} rotate:180  border: green_dark color: #white;
            		}
            }
            
            graphics "draw loading screen"{
            	
            	point center_for_loading_screen<-{68.75,24.4,1};
            	point offset_for_loading_screen <- {68.75,36,1};
            	
                   	
            	if(last=false){
            		
            		if (loading_ingredients=true){

            			draw message_loading_ingredients at:offset_for_loading_screen size:{40,12} rotate: 180;
            			
            		}
            		if (loading_recipe=true){
            			draw message_loading_recipe at:offset_for_loading_screen size:{40,19} rotate: 180;
            			
            		}
            		draw loading at: center_for_loading_screen size:{7,5} rotate: 180;
            		
            	}
            
            }
            
            graphics "proximity_graph" {
				if(draw_connections){

					loop eg over: proximity_graph.edges {
						geometry edge_geom <- geometry(eg);
						
						
						draw line(edge_geom.points) color:#green width: 6;
						int edge_distance_in_cms <- round(edge_geom.points[0] distance_to edge_geom.points[1]);
						
						
						point middle_of_the_line <- {((edge_geom.points[0].x+edge_geom.points[1].x)/2),((edge_geom.points[0].y+edge_geom.points[1].y)/2)+5};
						draw(string(edge_distance_in_cms)) color: #green rotate:90 at: middle_of_the_line font:font("SansSerif", 25 , #plain);

						}
					
			
				}
			}
        }
    }
}

experiment Move_Dev parent: MainVisualize type: gui {
  
    output {
        display objects_display_simulator parent: objects_display fullscreen: 0
        
        camera_pos: cam_position
        camera_look_pos: cam_look_pos
        camera_up_vector: cam_up_vector
        {
            species space position: {0, 0, -0.01} aspect: dev;
        }
    }
}


experiment Move parent: MainVisualize type: gui {    
    output {
        display objects_display_simulator parent: objects_display fullscreen: 1 keystone: arena_keystone 

        {
            species space position: {0, 0, -0.01} aspect:dev;
           
        }
    }
}
