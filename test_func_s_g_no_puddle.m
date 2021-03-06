function [successful_key_door_episodes, successful_key_episodes, successful_easy_episodes, successful_basic_key_door, scores_vec,scores_vec_basic,score_key,score_easy, total_episodes] = test_func_s_g_no_puddle(W_ih_big, b_ih_big, W_ho_big, b_ho_big)

nMeshx = 5; nMeshy = 5;

successful_key_door_episodes = [];
successful_key_episodes = [];
successful_basic_key_door = [];
successful_easy_episodes = [];

scores_vec = [];
score_key = [];
score_easy = [];
scores_vec_basic = [];

% Input of function approximator
xgridInput = 1.0 / nMeshx;
ygridInput = 1.0 / nMeshy;
xInputInterval = 0 : xgridInput : 1.0;
yInputInterval = 0 : ygridInput : 1.0;
xVector = xInputInterval;
yVector = yInputInterval;
xgrid = 1 / (nMeshx);
ygrid = 1 / (nMeshy);
% parameter of Gaussian Distribution
sigmax = 1.0 / nMeshx; 
sigmay = 1.0 / nMeshy;

ep_id = 1;
max_iter = 10*nMeshx;
total_episodes = 0;

for x=xInputInterval,
    for y=yInputInterval,
        key = initializeState(xInputInterval,yInputInterval);       
        door = initializeState(xInputInterval,yInputInterval);
        
        t = 1;
        scores = 0;
        agenthaskey = false;
        g = key;
        s=[x,y];
        while(t<=max_iter)
            if success(s,key) && ~agenthaskey
                scores = scores + 10;
                g = door;
                %fprintf('goal changed to %g %g \n',g);
                successful_key_episodes = [successful_key_episodes, ep_id];
                score_key = [score_key,scores];
                agenthaskey = true;
            end
            
            if agenthaskey
               if success(s,door)
                   scores = scores + 100;
                   successful_key_door_episodes = [successful_key_door_episodes, ep_id];
                   scores_vec = [scores_vec, scores];
                   break
               end
            end
            
            
             sx = sigmax * sqrt(2*pi) * normpdf(xInputInterval,s(1),sigmax);
             sy = sigmay * sqrt(2*pi) * normpdf(yInputInterval,s(2),sigmay);
             st = [sx,sy];                
             [Q,~,~,~] = kwta_NN_forward_s_g(st,g,nMeshx,nMeshy, W_ih_big,b_ih_big, W_ho_big,b_ho_big); 
             [~,a] = max(Q);
             sp1 = UPDATE_STATE(s,a,xgrid,xInputInterval,ygrid,yInputInterval);
             rew = 0;
             scores = scores + rew;
             s = sp1;
             t = t+1;
            if t == max_iter
                scores_vec = [scores_vec, scores];
                if ~agenthaskey
                    score_key = [score_key,scores];
                end
                    
            end
        end
                
        ep_id = ep_id + 1;
        total_episodes = total_episodes + 1;
    end
end

radius = 1.5*xgrid;
ep_id = 1;
for x=xInputInterval,
    for y=yInputInterval,
        t = 1;
        scores = 0;
        s0=[x,y];
        s = s0;
        g = neighbor_state_no_puddle(s0,xVector,yVector,radius);
        while(t<=max_iter)
            %fprintf('s = %g %g \n',s);
            if success(s,g)
                successful_easy_episodes = [successful_easy_episodes, ep_id];
                scores = scores + 10;
                score_easy = [score_easy,scores];
                break
            end
            
             sx = sigmax * sqrt(2*pi) * normpdf(xInputInterval,s(1),sigmax);
             sy = sigmay * sqrt(2*pi) * normpdf(yInputInterval,s(2),sigmay);

            % Using st as distributed input for function approximator
             st = [sx,sy];                
             [Q,~,~,~] = kwta_NN_forward_s_g(st,g,nMeshx,nMeshy, W_ih_big,b_ih_big, W_ho_big,b_ho_big); 
             [~,a] = max(Q);
             sp1 = UPDATE_STATE(s,a,xgrid,xInputInterval,ygrid,yInputInterval);             
             rew = 0;
             scores = scores + rew;
             s = sp1;
             t = t+1;
             if t == max_iter
                score_easy = [score_easy,scores];
             end

        end                
        ep_id = ep_id + 1;
    end
end

key = [0.0,0.0];
door = [1.0,1.0];
ep_id = 1;

for x=xInputInterval,
    for y=yInputInterval,
        t = 1;
        scores = 0;
        agenthaskey = false;
        g = key;
        s=[x,y];
        while(t<=max_iter)
            if success(s,key) && ~agenthaskey
                scores = scores + 10;
                g = door;
                agenthaskey = true;
            end
            
            if agenthaskey
               if success(s,door)
                   agentReached2Door = true;
                   scores = scores + 100;
                   successful_basic_key_door = [successful_basic_key_door, ep_id];
                   scores_vec_basic = [scores_vec_basic, scores];
                   break
               end
            end
                        
             sx = sigmax * sqrt(2*pi) * normpdf(xInputInterval,s(1),sigmax);
             sy = sigmay * sqrt(2*pi) * normpdf(yInputInterval,s(2),sigmay);

            % Using st as distributed input for function approximator
             st = [sx,sy];                  
             [Q,~,~,~] = kwta_NN_forward_s_g(st,g,nMeshx,nMeshy, W_ih_big,b_ih_big, W_ho_big,b_ho_big); 
             [~,a] = max(Q);
             sp1 = UPDATE_STATE(s,a,xgrid,xInputInterval,ygrid,yInputInterval);
             rew = 0;
             scores = scores + rew;
             
             s = sp1;
             t = t+1;
            if t == max_iter
                scores_vec_basic = [scores_vec_basic, scores];
            end
        end
                
        ep_id = ep_id + 1;
    end
end



