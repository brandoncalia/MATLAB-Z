function apocalypse_model
%{
Modeling The Possibility & Spread of a Zombie Apocalypse
Brandon Calia

With many movies, video games, and novels being made on the subject, the
possibility of a zombie outbreak is an appealing form of media. This 
agent-based simulation is meant to model an apocalypse using a very 
simplified set of rules. 

The model operates under the assumption that our domain consists of a 
city and its outskirts. Most of the population is concentrated in or very 
near the city.

There are almost endless factors to consider when it comes to modeling an
apocalypse - food supply, cliques, weapons, injuries, infection, fighting
ability, speed, humans killing each other, and the list goes on. In order 
to simplify, I condense all possible survival factors into a single 
coefficient - this is a human's "formidibility" rating.
 
Additionally, I consider the posibility of hostility between humans. This
need not be a fight to the death, but could be a competition for resources 
or space. This likelihood of malicious interaction is a human's "hostility"
rating. 

After the initial zombie is infected, humans and zombies move with random
motion. Those humans within a certain distance to a zombie will "interact"
with it - either killing it or becoming infected. Killing a zombie results
in an increase of formidibility. Similarly, humans within a very close 
distance to each other will interact if one of the two agents happens 
to be overly hostile (h>0.5) and is compartively more hostile than the
other. If the more hostile agent hits a random check with their
formidibility rating, they kill/outresource the opposing agent. This setup
accounts for all possibilities - a hostile agent attacking another agent,
two nonhostile agents "grouping up", or a hostile agent realizing he is
unequipped to fight the opposition and choosing to remain allies. The fact
that the hostility coefficient is fixed throughout the entirety of the
simulation creates natural cliques/alliances, specifically between
nonhostile agents.

To account for injuries, loss/gain of supplies, etc., humans have their
formidibility coefficients updated randomly every 10 steps. 

We observe how the fungus spreads over time and how well the human
population survives, particularly based on whether the outbreak begins in
the city or its outskirts. Additionally, note that the parameters/setup
outlined below account for most any possible situation - from the first
zombie being killed immediately (outbreak over) to over 50% of the
population becoming infected rapidly, and anything in between.
%}

% -------------------------------------------------------------------------
% Parameters
% -------------------------------------------------------------------------
N = 250; % Initial human population
city_pop = floor(N*.6); % Size of population in city
outer_pop = ceil(N*.4); % Size of population in outskirts
ns = 5000; % Number of steps
ax = [0 250 0 250]; % Domain

% -------------------------------------------------------------------------
% Initialization
% -------------------------------------------------------------------------
H = zeros(N,4); % Array of parameters for humans 
% Set the x and y positions of humans:
H(1:city_pop,1:2) = normrnd(max(ax)/4,max(ax)/12,city_pop,2); % In city
H(city_pop+1:N,1:2) = rand(outer_pop,2)*max(ax); % In outskirts
% Initialize behavioral coefficients:
H(:,3) = rand(N,1)*0.5; % Formidability (humans start with low value)
H(:,4) = rand(N,1); % Hostility 
Z = normrnd(max(ax)/4,max(ax)/50,1,2); % Set coordinates of first zombie in city
% Z = rand(1,2)*max(ax); % Uncomment to spawn zombie randomly
Dh = rand(size(H,1),1)*2*pi; % Initial direction of humans motion
Dz = rand(size(Z,1),1)*2*pi; % Initial direction of zombie motion
v = .75; % Speed of agents (distance traveled per step)
pts = []; % Keep track of each step for plotting
avg_formids = []; % Keep track of average formidibility for plotting
avg_hosts = [];
outbreak = false;

% -------------------------------------------------------------------------
% Computation
% -------------------------------------------------------------------------
for j = 1:ns % Loop over each timestep
    
    idx_infect = []; % Indices of humans infected each step
    idx_zkill = []; % Indices of zombies killed each step
    idx_hkill = []; % Indices of humans killed each step
    
    % Update positions and directions
    H(:,1) = H(:,1)+v*cos(Dh); 
    H(:,2) = H(:,2)+v*sin(Dh);
    Z(:,1) = Z(:,1)+v*cos(Dz); 
    Z(:,2) = Z(:,2)+v*sin(Dz);
    Dh = Dh+0.1*randn(size(Dh));
    Dz = Dz+0.1*randn(size(Dz));
    
    % Let human agents bounce off walls:
    ind = (H(:,1)<ax(1)&cos(Dh)<0)|(H(:,1)>ax(2)&cos(Dh)>0);
    Dh(ind) = pi-Dh(ind); % Reverse x direction
    ind = (H(:,2)<ax(3)&sin(Dh)<0)|(H(:,2)>ax(4)&sin(Dh)>0);
    Dh(ind) = -Dh(ind); % Reverse y direction

    % Let zombie agents bounce off walls: 
    ind = (Z(:,1)<ax(1)&cos(Dz)<0)|(Z(:,1)>ax(2)&cos(Dz)>0); 
    Dz(ind) = pi-Dz(ind); % Reverse x direction
    ind = (Z(:,2)<ax(3)&sin(Dz)<0)|(Z(:,2)>ax(4)&sin(Dz)>0);
    Dz(ind) = -Dz(ind); % Reverse y direction
    
    % Move agents outside domain back in:
    H(:,1) = min(max(H(:,1),ax(1)),ax(2)); 
    H(:,2) = min(max(H(:,2),ax(3)),ax(4)); 
    Z(:,1) = min(max(Z(:,1),ax(1)),ax(2)); 
    Z(:,2) = min(max(Z(:,2),ax(3)),ax(4)); 
    
    % Determine if we have reached outbreak status. This will not occur
    % unless more than 5 steps have passed and the zombies have infected at 
    % least 2.5% of the original population.
    if j > 5 && size(Z,1) > 0.025*N
        outbreak = true;
    end
    
    % Agent interaction computations:
    if j ~= 1 % Do not compute before first zombie is plotted
        for w = 1:size(H,1) % Loop over each human
            for q = 1:size(Z,1) % Loop over each zombie
                % If human is within distance of zombie and the zombie
                % has not already been killed by a previous human in the
                % loop, we begin an interaction:
                if norm(H(w,1:2)-Z(q,1:2)) <= max(ax)/25 && ~ismember(q, idx_zkill)
                    % If human has too little formidability to kill zombie,
                    % they become infected:
                    if rand>=H(w,3)
                        idx_infect = [idx_infect, w]; % Indicies to be infected
                    else % Otherwise kill zombie
                        idx_zkill = [idx_zkill, q]; % Zombie indices to be killed
                        H(w,3) = H(w,3) + .1; % Increase human's formidability
                        H(w,3) = min(H(w,3),.99); % But must be < 1
                    end
                end
            end
            % Now we check for human-human interactions. Humans do not 
            % become hostile/desperate until we reach outbreak status. 
            if outbreak
                for i = 1:size(H,1) % Loop over each human
                    % We must check the following to verify an interaction:
                    % Humans must be within distance to form a conflict, 
                    % agent cannot interact with itself, and agent cannot
                    % already be dead or infected from previous
                    % interactions
                    if norm(H(w,1:2)-H(i,1:2)) <= max(ax)/50 && w ~= i &&...
                            ~ismember(i,idx_hkill) && ~ismember(i,idx_infect)
                        % Now we check the hostility of each agent:
                        % If the more hostile of the two has a hostility
                        % coefficient exceeding 0.5 and also has the 
                        % requisite fomidibility (hits a random check), 
                        % they will kill/outresource the opposing agent.
                        % Doing so increases the winning agent's 
                        % formidibility:
                        if H(w,4) > H(i,4) && H(w,4) > 0.5 && rand <= H(w,3)
                            idx_hkill = [idx_hkill, i]; % Indices which die
                            H(w,3) = H(w,3) + .1; % Increase formidability
                            H(w,3) = min(H(w,3),.99); % But must be < 1
                        end
                    end
                end
            end
        end
    end
    
    % Update all arrays:
    deaths = unique([idx_infect idx_hkill]); % Record deaths
    Z(idx_zkill,:) = []; % Remove killed zombies
    Dz(idx_zkill,:) = []; % Remove killed zombies from directional array
    Z = [Z;H(idx_infect,1:2)]; % Add newly infected humans to zombie array
    Dz = [Dz;Dh(idx_infect,:)]; % Add newly infected humans to directional array
    H(deaths,:) = []; % Remove dead humans
    Dh(deaths,:) = []; % Remove dead humans from directional array
    
    % Every 10 steps we randomly update formidibility coefficients, so long
    % as the outbreak is viral enough. This simulates any changes in
    % survival factors that occur in the chaos of the apocalypse. 
    if mod(j,10) == 0 && outbreak
        H(:,3) = H(:,3) + normrnd(0,0.1,size(H,1),1);
        H(:,3) = max(min(H(:,3),0.99),.01); % 0<f<1
    end
    
    % Record average human formidibility and the step at which it occurs
    avg_formid = sum(H(:,3)) / size(H,1);
    avg_formids = [avg_formids avg_formid]; 
    avg_host = sum(H(:,4)) / size(H,1);
    avg_hosts = [avg_hosts avg_host];
    pts = [pts j];
    
    % Plot layout
    clf
    t = tiledlayout(2,2);
    t.Padding = 'compact';
    t.TileSpacing = 'compact';
    
    % Plot humans and zombies in space
    nexttile
    hold on
    plot(H(:,1),H(:,2),'k.','markersize',11)
    plot(Z(:,1),Z(:,2),'r.','markersize',11)
    grid on
    axis equal xy, axis(ax)
    title('Modeling The Zombie Apocalypse')
    
    % Plot human population over time
    nexttile
    pie([size(H,1), size(Z,1)])
    title('Tracking human population')
    legend({'Humans','Zombies'},'location','northeastoutside')
    colormap jet
    
    % Plot average human formidibility over time
    nexttile
    plot(pts,avg_formids, 'b.-', 'markersize',8)
    grid on
    title('Avg Formidability Over Time')
    xlabel('Step')
    ylabel('Average formid.')
    
    % Plot average human hostility over time
    nexttile
    plot(pts,avg_hosts, 'r.-', 'markersize',8)
    grid on
    title('Avg Hostility Over Time')
    xlabel('Step')
    ylabel('Average host.')
    drawnow
    
    % Allow time to see initial conditions before simulation starts:
    if j==1
        pause(5)
    end
    
    % If no zombies remain or if zombies overtake the population, 
    % simulation ends
    if size(Z,1) == 0 || size(H,1) == 0
        return
    end
    
end