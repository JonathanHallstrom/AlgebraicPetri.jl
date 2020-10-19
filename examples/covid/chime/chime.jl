using AlgebraicPetri
using AlgebraicPetri.Epidemiology
using OrdinaryDiffEq
using LabelledArrays
using Plots
using Catlab.Theories
using Catlab.CategoricalAlgebra.FreeDiagrams
using Catlab.Graphics

display_wd(ex) = to_graphviz(ex, orientation=LeftToRight, labels=true);

sir = transmission ⋅ recovery

p_sir = apex(F_epi(sir));
display_wd(sir)
#-
Graph(p_sir)

u0 = LVector(S=990, I=10, R=0);
t_span = (17.0,120.0)

γ = 1/14
β = t->begin
    policy_days = [20,60,120] .+ 17
    contact_rate = 0.05
    pol = findfirst(x->t<=x, policy_days) # array of days when policy changes
    growth_rate = pol == 1 ? 0.0 : (2^(1/((pol-1)*5)) - 1) # growth rate depending on policy
    return (growth_rate + γ) / 990 * (1-contact_rate) # calculate rate of infection
end
p = LVector(inf=β, rec=γ);

prob = ODEProblem(vectorfield(p_sir),u0,t_span,p)
sol = OrdinaryDiffEq.solve(prob,Tsit5())
plot(sol)
png("ode-chime.png")