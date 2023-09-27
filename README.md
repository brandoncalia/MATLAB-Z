# MATLAB-Z
An agent-based model in MATLAB that simulates a theoretical zombie apocalypse (or other disease outbreak)

Brandon Calia



# Introduction
The idea of a zombie apocalypse has been explored countless times in video games, movies, and TV shows. It’s a pop culture phenomenon with endless possibilities, all centered around the idea of an infectious disease turning people into undead, infectious, and hostile beings, hungry to infect whoever they see. My model attempts to provide a very simplistic parameterization and visualization of how a population would survive given an outbreak of a zombie-like fungus. Unsurprisingly, many people have tried to delve into the idea of modeling such a pandemic. Most models are simply derivatives of already advanced disease models, with lots using a variation of the SIR model we discussed in class. One such famous model was developed by Alex Alemi, a statistician from Cornell who built an interactive model using previously developed disease models. He adds two more specific variables, namely those representing the “bite to kill ratio” and the time for a zombie to walk one mile. 

# Model Contruction & Parameters
I wanted to create a model that wasn’t necessarily just a fork of a disease model, but something that more accurately represented some of the phenomena we see in video games and movies about the zombie apocalypse. However, this would be far too complicated to encode into a more basic model. There are infinite factors to consider - food supply, weapons, gangs, injuries, types of zombies, bases/forts, government intervention, etc. I therefore choose to simplify all these factors into two more basic coefficients. The first of the two I refer to as “formidability (f).” The variable f is a concatenation of all the survival factors that play into a human’s chance of staying alive. This accounts for food, weapons, fighting ability, injuries, age, intelligence, etc. I refer to the second coefficient used to describe the simulation as “hostility (h)”. All zombie media always has some depiction of humans fighting over land, resources, or weapons, or even just people dying in the chaos. h describes how hostile a human agent is towards any other human agent. Both h and f are numbers between 0 and 1 exclusive, chosen uniformly. However, to begin (although the value may change throughout the simulation) f is assigned as a number between 0 and 0.5. It is most logical to give humans a lower-than-maximum cap on f to begin, since they have no experience fighting zombies or surviving in such a situation. 

There are two types of agents - humans and zombies. We model the environment such that it contains a city and its outskirts, with most of the population being concentrated in or around the city. Human agents have four attributes. An x position, y position, formidability coefficient, and hostility coefficient. Zombie agents only store an x and y position. The outbreak begins with a single infected agent, with all agents following random movement. I chose a domain of [0,250]x[0,250].

The first type of interaction to check for is between humans and zombies. If the human is within interaction distance (variable) of a zombie, then they engage. Roll a random number between 0 and 1. If the human’s value of f is less than the rolled value, the human is bitten and infected. Else, the human kills the zombie. I thought it logical that upon successfully killing a zombie, humans should have their formidability slightly increased. 
 
Next, we must check for human-human interactions. However, there are other factors to consider before this interaction can be described. When programming this in the earlier stages, an immediate problem was that humans were all going off and killing each other before even 10 zombies were within the domain. Define an additional boolean state of the simulation, called “outbreak.”  This variable simply checks whether or not this virus has hit the status of a known pandemic. After such a check is verified, chaos ensues, and humans will begin attacking each other or fighting for resources. If two humans are in interaction distance, check each of their values for h. Only consider an interaction if at least one agent has h>0.5. This is done to ensure that not every agent actually has the possibility of killing every other agent. It is a way of creating artificial cliques within this simulation, a very realistic phenomenon. If an interaction does occur, the human with the higher hostility value attacks/competes. Their chance to kill/outresource the opposing human should depend on this agent’s formidability. So, roll a random number from 0-1, and check whether or not it exceeds this agent’s value for f. If not, they will kill/outresource the opposing agent. It again makes sense that the winning agent has their value of f increased slightly. Assuming the status of the “outbreak” variable is true, we also update each human’s formidability with a random normal variable every 10 steps. This is to account for changes in survival factors (injuries, weapons, etc.) that occur naturally in such a pandemic. 


# Results
There are three main results that stick out in this model. Firstly, the described setup allows for a very wide range of possibilities. Many times, humans are able to actually kill the very first zombie agent that spawns. Other times, zombies overtake 40% of the domain’s population rapidly. This result specifically is interesting. See below how quickly zombies can take over a large portion of the city population (approximately 15 timesteps). 

<img width="450" alt="zombies1" src="https://github.com/brandoncalia/MATLAB-Z/assets/41372799/29e88c6f-6909-4c17-8014-cb9a40a5c975">


Two important things to track in this simulation are the way average human formidability and average human hostility change over time. Interesting enough, both increase as time continues. The increase of f with time is extremely logical - it’s simply survival of the fittest. f essentially dictates an agent’s likelihood to survive a hostile interaction, so it makes sense that weaker agents would die and stronger agents would survive. The increase in average hostility over time was very intriguing, however. It isn’t illogical, but such a clear increase over time did surprise me, since in no way does hostility dictate whether or not an agent survives an interaction. That being said, it does dictate whether or not a human attacks another human. It does follow (based on the behaviors in this model) that a higher likelihood of being the attacker and not the attacked will lead to generally greater survival odds within the realm of human-human interactions. See below both variables changing with time: 

<img width="400" alt="zombie2" src="https://github.com/brandoncalia/MATLAB-Z/assets/41372799/b0d289eb-1f18-4de7-8625-22802726231b">



The apocalypse is a very complex phenomena that is difficult to model the way we see plots play out in movies. In doing this project, I learned an efficient way to simplify a complex procedure into a more basic set of interactions and rules. I was also glad to see results confirming that my choice of update rules was not unfounded, with a clear survival of the fittest trend and a visualization plot that doesn’t yield unexpected or impossible scenarios. One thing I think the model could benefit from is more realistic patterns of agent grouping. In a real apocalypse, it makes sense that people would travel in packs. Although it is somewhat artificially created through the fact that not every human agent is hostile towards every other human agent, this behavior is generally lacking. A more major thing I would like to add to this project to improve it would be the encoding of a cure. Rather, some possibility of a cure being found in a given timeframe, with then separate rules to dictate how the cure gets distributed. These two additions could make for an even more realistic, but still simplified model of the zombie apocalypse. 


# Works Cited 
“Mapping the Zombie Apocalypse.” Cornell Chronicle, 5 Mar. 2015, 
news.cornell.edu/essentials/2015/03/mapping-zombie-apocalypse. Accessed 09 May 
2023. 

Munz, Philip, et al. When Zombies Attack!: Mathematical Modelling of an Outbreak of Zombie 
Infection, loe.org/images/content/091023/Zombie%20Publication.pdf. 
