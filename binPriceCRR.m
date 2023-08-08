function oPrice = binPriceCRR(X,S0,r,sig,dt,steps,oType,early)

% Implementation of the code follows closely from the original author Dr. Phil Goddard

% Inputs
% X - strike
% S0 - stock price
% r - risk free interest rate
% sig - volatility
% dt - time step
% steps - number of steps
% oType - 'CALL' or 'PUT'
% early - true for American, false for European.

% Output
% oPrice - option price

% model parameters
a = exp(r*dt);
u = exp(sig*sqrt(dt));
d = 1/u;
p = (a-d)/(u-d);

% underlying price tree
priceTree = nan(steps+1,steps+1);
priceTree(1,1) = S0;
for idx = 2:steps+1
    priceTree(1:idx-1,idx) = priceTree(1:idx-1,idx-1)*u;
    priceTree(idx,idx) = priceTree(idx-1,idx-1)*d;
end

% option price at expiry
valueTree = nan(size(priceTree));
switch oType
    case 'PUT'
        valueTree(:,end) = max(X-priceTree(:,end),0);
    case 'CALL'
        valueTree(:,end) = max(priceTree(:,end)-X,0);
end

% option price at earlier times
steps = size(priceTree,2)-1;
for idx = steps:-1:1
    valueTree(1:idx,idx) = exp(-r*dt)*(p*valueTree(1:idx,idx+1) + (1-p)*valueTree(2:idx+1,idx+1));
    if early
        switch oType
            case 'CALL'
                valueTree(1:idx,idx) = max(priceTree(1:idx,idx)-X,valueTree(1:idx,idx));
            case 'PUT'
                valueTree(1:idx,idx) = max(X-priceTree(1:idx,idx),valueTree(1:idx,idx));
        end
    end
end

% option price
oPrice = valueTree(1);