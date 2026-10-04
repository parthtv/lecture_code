# Runs the cbopt and t2c scenarios of DICEModel.jl and writes a tidy CSV.
# Usage: julia --project=dice_julia dice_julia/run_scenarios.jl <output.csv>
using DICEModel

out = isempty(ARGS) ? "dice_scenario_results.csv" : ARGS[1]
open(out, "w") do io
    println(io, "scenario,year,scc,cprice,abate_share,tatm,miu")
    for sc in ["cbopt", "t2c"]
        r = run_dice_scenario(sc)
        r.solved || error("Scenario $sc did not solve: $(r.status)")
        for i in eachindex(r.times)
            println(io, "$sc,$(2020 + r.times[i]),$(r.scc[i]),$(r.CPRICE_R[i,1]),$(r.abaterat[i]),$(r.TATM[i]),$(r.MIU[i])")
        end
    end
end
