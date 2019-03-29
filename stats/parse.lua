SRC = ...

local m = require 'lpeg'
local P, S, C, R, Ct, Cc = m.P, m.S, m.C, m.R, m.Ct, m.Cc

local SPC  = S'\t\n\r '
local X    = SPC ^ 0
local NUMS = R'09' ^ 1

local SEQ = Ct(
    P'-- Sequencia ' * X * NUMS * X * P'-'^1 * P'\r\n'      *
    (P'    ****' * Cc(true) + P'            ****' * Cc(false))  * X *
    Ct( (P'!'^-1 *X* NUMS *X* P'!'^-1 *X*
        P'(' * C(NUMS) *X* P'/' *X* NUMS * P')' * X)^1 )    * X *
    P'!'^-1 *X* NUMS *X* P'!'^-1                            * X *
    P'-----   -----' * X * NUMS * X * NUMS                  * X *
    P(0))

local patt =
    P'relatorio'^-1                         * X *
    P'-'^1                                  * X *
    C((1-SPC)^0)                            * X *   -- Joao
    P'/'                                    * X *
    C((1-SPC)^0)                            * X *   -- Maria
    P'(' * C(NUMS) * 'cm'                   * X *   -- 750cm
    P'-'                                    * X *
    C(NUMS) * 's' * ')'                     * X *   -- 180s
    P'-'^0                                  * X *
    P'TOTAL:'  * X * C(NUMS)                * X *   -- 3701 pontos
    P'Tempo:'  * X * C(NUMS) * 'ms (-0s)'   * X *   -- 180650 (-0s)
    P'Quedas:' * X * C(NUMS)                * X *   -- 6 quedas
    P'Golpes:' * X * C(NUMS)                * X *   -- 286 golpes
    P'Ritmo:'  * X * C(NUMS) *'/'* C(NUMS)  * X *   -- 45/45 kmh
    (1-NUMS)^1 * C(NUMS)                    * X *   -- Joao: 5500
    P'[' * Ct((X * C(NUMS))^1) *X* '] =>' *X* C(NUMS) * X *   -- [ ... ]
    P'[' * Ct((X * C(NUMS))^1) *X* '] =>' *X* C(NUMS) * X *   -- [ ... ]
    (1-NUMS)^1 * C(NUMS)                    * X *   -- Maria: 4427
    P'[' * Ct((X * C(NUMS))^1) *X* '] =>' *X* C(NUMS) * X *   -- [ ... ]
    P'[' * Ct((X * C(NUMS))^1) *X* '] =>' *X* C(NUMS) * X *   -- [ ... ]
    Ct(SEQ^1)                               * X *
    P'--------------------------------'     * X *
    P'Atleta    Vol     Esq     Dir   Total' * X*
    (1-NUMS)^0 * C(NUMS) *X* '+' *X* C(NUMS) *X* '+' *X* C(NUMS) *X* '=' *X* C(NUMS) * X *
    (1-NUMS)^0 * C(NUMS) *X* '+' *X* C(NUMS) *X* '+' *X* C(NUMS) *X* '=' *X* C(NUMS) * X *
    P'Media:'      *X* C(NUMS) *X*
    P'Equilibrio:' *X* C(NUMS) *X* '(-)' *X*
    P'Quedas:'     *X* C(NUMS) *X* '(-)' *X*
    P'FINAL:'      *X* C(NUMS) *X*
    P(0)
             
local esquerda, direita, distancia, tempo, total, _, quedas, golpes,
      ritmo1, ritmo2, p0, esqs0,esq0,dirs0,dir0, p1, esqs1,esq1,dirs1,dir1,
      seqs,
      _vol0, _esq0, _dir0, _tot0,
      _vol1, _esq1, _dir1, _tot1,
      _media, _equilibrio, _quedas, _final = patt:match(assert(io.open(SRC)):read'*a')

assert(total==_final and p0==_tot0 and p1==_tot1)

local nomes  = { esquerda, direita }
local pontos = { {_tot0,_vol0,_esq0,_dir0}, {_tot1,_vol1,_esq1,_dir1} }
local ritmos = { {0,esq0,dir0}, {0,esq1,dir1} }
local lefts  = { esqs0, esqs1 }
local rights = { dirs0, dirs1 }
local hits = { {}, {} }
    for _,seq in ipairs(seqs) do
        local isesq, vels = table.unpack(seq)
        for i,vel in ipairs(vels) do
            local idx do
                if isesq then
                    if i%2 == 1 then
                        idx = 1
                    else
                        idx = 2
                    end
                else
                    if i%2 == 1 then
                        idx = 2
                    else
                        idx = 1
                    end
                end
            end
            ritmos[idx][1] = ritmos[idx][1] + vel*vel
            hits[idx][#hits[idx]+1] = vel
        end
    end
    ritmos[1][1] = math.floor(math.sqrt(ritmos[1][1]/#hits[1]))
    ritmos[2][1] = math.floor(math.sqrt(ritmos[2][1]/#hits[2]))
assert(tonumber(golpes) == (#hits[1]+#hits[2]))

assert(#seqs == quedas+1)
print(esquerda, direita)

for i,seq in ipairs(seqs) do
    print('SEQ', i)
    local isesq, all = table.unpack(seq)
    print(isesq, all)
    for _,v in ipairs(all) do
        print('',v)
    end
end

function player (i)
    local ret = "{\n"
    ret = ret .. "\t\t'nome'   : '"..nomes[i].."',\n"
    ret = ret .. "\t\t'golpes' : "..#hits[i]..",\n"
    ret = ret .. "\t\t'pontos' : ("..table.concat(pontos[i],',').."),\n"
    ret = ret .. "\t\t'ritmo'  : ("..table.concat(ritmos[i],',').."),\n"
    ret = ret .. "\t\t'left'   : ("..table.concat(lefts[i],',').."),\n"
    ret = ret .. "\t\t'right'  : ("..table.concat(rights[i],',').."),\n"
    ret = ret .. "\t\t'hits'   : ("..table.concat(hits[i],',').."),\n"
    ret = ret .. "\t}\n"
    return ret
end

local ts = string.sub(SRC, 8, string.len(SRC)-4)
local out = assert(io.open('x.py','w'))
out:write("GAME = {\n")
out:write("\t'timestamp' : '"..ts.."',\n")
out:write("\t'distancia' : "..distancia..",\n")
out:write("\t'tempo'     : "..tempo..",\n")
out:write("\t'pontos'    : (".._final..",".._media..",".._equilibrio..",".._quedas.."),\n")
out:write("\t'ritmo'     : ("..ritmo1..","..ritmo2.."),\n")
out:write("\t'golpes'    : "..golpes..",\n")
out:write("\t'quedas'    : "..quedas..",\n")
out:write("\t0           : "..player(1)..",\n")
out:write("\t1           : "..player(2)..",\n")
out:write("}\n")
out:close()
