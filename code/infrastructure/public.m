function this = public(varargin)
%function s = public(varargin)
%
%Given a bunch of function handles and variables to publically expose,
%PUBLIC creates a closure-based reference object.
%
%The arguments are all closures implementing the public methods.
%
%Unlike the object produced using FINAL, this one can be dynamically
%modified. New objects can inherit behavior from this one.

%TODO: something about interfaces (duck-typing for the win?)

% ----- implementation -----
% This is sort of tricky, but shows how very powerful closures are.

%To allow ancestor code to call into inheritor code, we need
%to be able to effectively modify the 'this' structure that the ancestor
%code holds onto -- OR have the 'this' refer to something we can modify.

%Start with a 'final' object. But we keep it in this closure, and will
%instead return an indirection pointing to the core.
core = final(varargin{:});
this = publicize(core);

    %implementation note: if we instead of a struct of wrappers used a
    %MATLAB object with overridden subsref(), the parent could call down
    %into methods it didn't even declare -- sort of an abstract base class.
    %For now I'm interested in using as few MATLAB objects as possible (how
    %fast is subsref dispatch vs. indirect struct lookup and funciton
    %handle dispatch?)

end