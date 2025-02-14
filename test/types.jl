using Tables
import Petri

sir_petri = PetriNet(3, ((1, 2), (2, 2)), (2, 3))
sir_lpetri = LabelledPetriNet([:S, :I, :R], :inf => ((:S, :I), (:I, :I)), :rec => (:I, :R))
sir_rxn = ReactionNet{Number,Int}([990, 10, 0], (0.001, ((1, 2) => (2, 2))), (0.25, (2 => 3)))
sir_lrxn = LabelledReactionNet{Number,Int}((:S => 990, :I => 10, :R => 0), (:inf, 0.001) => ((:S, :I) => (:I, :I)), (:rec, 0.25) => (:I => :R))

sir_tpetri = PetriNet(TransitionMatrices(sir_petri))

@test snames(sir_petri) == 1:3
@test tnames(sir_petri) == 1:2
@test snames(sir_lpetri) == [:S, :I, :R]
@test tnames(sir_lpetri) == [:inf, :rec]
@test snames(sir_rxn) == 1:3
@test tnames(sir_rxn) == 1:2
@test snames(sir_lrxn) == [:S, :I, :R]
@test tnames(sir_lrxn) == [:inf, :rec]

for pn ∈ [sir_petri, sir_lpetri, sir_rxn, sir_lrxn]
  @test PetriNet(pn) == sir_petri
end

for pn ∈ [sir_lpetri, sir_lrxn]
  @test LabelledPetriNet(pn) == sir_lpetri
end
for pn ∈ [sir_petri, sir_lpetri, sir_rxn, sir_lrxn]
  @test LabelledPetriNet(pn, [:S, :I, :R], [:inf, :rec]) == sir_lpetri
end

for pn ∈ [sir_rxn, sir_lrxn]
  @test ReactionNet{Number,Int}(pn) == sir_rxn
end
for pn ∈ [sir_petri, sir_lpetri, sir_rxn, sir_lrxn]
  @test ReactionNet{Number,Int}(pn, [990, 10, 0], [0.001, 0.25]) == sir_rxn
end

for pn ∈ [sir_lrxn]
  @test LabelledReactionNet{Number,Int}(pn) == sir_lrxn
end
for pn ∈ [sir_petri, sir_rxn]
  @test LabelledReactionNet{Number,Int}(pn, [:S => 990, :I => 10, :R => 0], [:inf => 0.001, :rec => 0.25]) == sir_lrxn
end
for pn ∈ [sir_petri, sir_lpetri, sir_rxn, sir_lrxn]
  @test LabelledReactionNet{Number,Int}(pn, [:S, :I, :R], [:inf, :rec], [990, 10, 0], [0.001, 0.25]) == sir_lrxn
end

β(u, t) = 1 / sum(u)
γ = 0.25
sir_rxn = ReactionNet{Function,Int}([990, 10, 0], (β) => ((1, 2) => (2, 2)), (t -> γ) => (2 => 3))
open_sir_rxn = Open([1, 2], sir_rxn, [3])
open_sir_lrxn = Open([:S, :I], sir_lrxn, [:R])

@test sir_tpetri == sir_petri
@test Petri.Model(sir_petri) == Petri.Model(sir_rxn)
@test Petri.Model(sir_lpetri) == Petri.Model(sir_lrxn)

@test typeof(Graph(sir_petri)) == Graph
@test typeof(Graph(sir_lpetri)) == Graph
@test typeof(Graph(sir_rxn)) == Graph
@test typeof(Graph(open_sir_rxn)) == Graph
@test typeof(Graph(sir_lrxn)) == Graph
@test typeof(Graph(open_sir_lrxn)) == Graph

@test inputs(sir_petri, 1) == [1, 2]
@test outputs(sir_petri, 1) == [2, 2]
@test concentration(sir_rxn, 1) == 990
@test rate(sir_rxn, 1) == β

@test concentrations(sir_rxn) == [990, 10, 0]
@test typeof(rates(sir_rxn)) <: Array{Function}

@test concentrations(sir_lrxn) == LVector(S=990, I=10, R=0)
@test rates(sir_lrxn) == LVector(inf=0.001, rec=0.25)

@test length(Tables.rows(tables(dom(open_sir_rxn).ob).S)) == length(Tables.rows(tables(dom(open_sir_lrxn).ob).S))

du = [0.0, 0.0, 0.0]
out = vectorfield(sir_rxn)(du, concentrations(sir_rxn), rates(sir_rxn), 0.01)
@test out[1] ≈ -9.9
@test out[2] ≈ 7.4
@test out[3] ≈ 2.5

du = [0.0, 0.0, 0.0]
out = vectorfield_expr(sir_rxn)(du, concentrations(sir_rxn), rates(sir_rxn), 0.01)
@test out[1] ≈ -9.9
@test out[2] ≈ 7.4
@test out[3] ≈ 2.5

du = LVector(S=0.0, I=0.0, R=0.0)
out = vectorfield(sir_lrxn)(du, concentrations(sir_lrxn), rates(sir_lrxn), 0.01)
@test out.S ≈ -9.9
@test out.I ≈ 7.4
@test out.R ≈ 2.5

du = LVector(S=0.0, I=0.0, R=0.0)
out = vectorfield_expr(sir_lrxn)(du, concentrations(sir_lrxn), rates(sir_lrxn), 0.01)
@test out.S ≈ -9.9
@test out.I ≈ 7.4
@test out.R ≈ 2.5

@test ns(sir_petri) == 3
add_species!(sir_petri)
@test ns(sir_petri) == 4

@test nt(sir_petri) == 2
add_transitions!(sir_petri, 2)
@test nt(sir_petri) == 4

@test ni(sir_petri) == 3
@test no(sir_petri) == 3
add_input!(sir_petri, 3, 1)
add_output!(sir_petri, 3, 4)
add_input!(sir_petri, 4, 4)
add_output!(sir_petri, 4, 3)
@test ni(sir_petri) == 5
@test no(sir_petri) == 5
@test sir_petri == PetriNet(4, ((1, 2), (2, 2)), (2, 3), (1, 4), (4, 3))

# test flatten_symbols
tuple_labelled = AlgebraicPetri.LabelledPetriNetUntyped{Tuple{Symbol,Symbol}}()
tuple_rxn = AlgebraicPetri.LabelledReactionNetUntyped{Int,Int,Tuple{Symbol,Symbol}}()
for tuple_petri in [tuple_labelled, tuple_rxn]
  add_species!(tuple_petri, 3, sname=((:U, :S), (:U, :I), (:U, :R)))
  add_transitions!(tuple_petri, 2, tname=((:Q, :inf), (:Q, :rec)))

  tuple_petri′ = tuple_petri |> flatten_labels

  @test tuple_petri′ == flatten_labels(tuple_petri′)
  @test tuple_petri′[:, :sname] == [:U_S, :U_I, :U_R]
  @test tuple_petri′[:, :tname] == [:Q_inf, :Q_rec]
end

# Property Petri Nets
sir_petri = PetriNet(3, ((1, 2), (2, 2)), (2, 3))
sir_lpetri = LabelledPetriNet([:S, :I, :R], :inf => ((:S, :I), (:I, :I)), :rec => (:I, :R))
sir_rxn = ReactionNet{Function,Int}([990, 10, 0], (β) => ((1, 2) => (2, 2)), (t -> γ) => (2 => 3))
sir_lrxn = LabelledReactionNet{Number,Int}((:S => 990, :I => 10, :R => 0), (:inf, 0.001) => ((:S, :I) => (:I, :I)), (:rec, 0.25) => (:I => :R))

sir_sprops = [
  Dict(:title => "Susceptible", :unit => "People"),
  Dict(:title => "Infected", :unit => "People"),
  Dict(:title => "Recovered", :unit => "People"),
]
sir_sprops_dict = Dict(:S => sir_sprops[1], :I => sir_sprops[2], :R => sir_sprops[3])

sir_tprops = [
  Dict(:title => "Infection", :description => "An infected person interacts with a suscpetible person and the susceptible person becomes infected."),
  Dict(:title => "Recovery", :description => "An infected person recovers from their illness."),
]
sir_tprops_dict = Dict(:inf => sir_tprops[1], :rec => sir_tprops[2])

sir_proppetri = PropertyPetriNet{Dict}(sir_petri, sir_sprops, sir_tprops)
@test PetriNet(sir_proppetri) == sir_petri

@test sir_sprops == sprops(sir_proppetri)
@test sir_tprops == tprops(sir_proppetri)

sir_proplpetri = PropertyLabelledPetriNet{Dict}(sir_lpetri, sir_sprops_dict, sir_tprops_dict)
@test LabelledPetriNet(sir_proplpetri) == sir_lpetri

sir_proprxn = PropertyReactionNet{Function,Int,Dict}(sir_rxn, sir_sprops, sir_tprops)
@test ReactionNet{Function,Int}(sir_proprxn) == sir_rxn

sir_proplrxn = PropertyLabelledReactionNet{Number,Int,Dict}(sir_lrxn, sir_sprops_dict, sir_tprops_dict)
@test LabelledReactionNet{Number,Int}(sir_proplrxn) == sir_lrxn

for p in [sir_proppetri, sir_proprxn]
  @test Open(p, [1], [2], [3]) == Open(p)
end

for p in [sir_proplpetri, sir_proplrxn]
  @test Open(p, [:S], [:I], [:R]) == Open(p)
end
