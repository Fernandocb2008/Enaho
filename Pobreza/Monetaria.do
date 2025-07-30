

** pobreza monetaria


 clear all

use sumaria-2019, clear //La base está a nivel de hogares
append using sumaria-2017
append using sumaria-2018

gen factorpob=round(factor07*mieperho,2)

*Área
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

tab pobreza [fw=factorpob] 
tab area pobreza [fw=factorpob] 

******
gen dpto= real(substr(ubigeo,1,2))
replace dpto=15 if (dpto==7)
label define dpto 1 "Amazonas" 2"Ancash" 3"Apurimac" 4"Arequipa" 5"Ayacucho" 6"Cajamarca" 8"Cusco" 9"Huancavelica" 10"Huanuco" 11"Ica" 12"Junin" 13"La_Libertad" 14"Lambayeque" 15"Lima" 16"Loreto" 17"Madre_de_Dios" 18"Moquegua" 19"Pasco" 20"Piura" 21"Puno" 22"San_Martin" 23"Tacna" 24"Tumbes" 25"Ucayali" 
lab val dpto dpto 

*gasto total percápita
gen gpcm=gashog2d/(12*mieperho)

*ingreso percapita
gen ingpc=inghog1d/(12*mieperho)

ren aÑo año
destring año,replace

*pobre
gen pobre=(pobreza==1 | pobreza==2) //genera dummys en función de la condición
replace pobre=pobre*100

lab def pobre 1 "Pobre" 0 "No pobre"
lab val pobre pobre
tab pobre [fw=factorpob] 
tabulate area pobre [fw=factorpob],col 

***
svyset [pweight = factorpob], psu(conglome) strata(estrato)
svy:mean pobre, over(año)
svy:mean pobre if año==2019, over(dpto)

svy: mean pobre if año==2019,  over(dpto) 
lincom pobre@1.dpto - pobre@2.dpto
lincom pobre@1.dpto - pobre@3.dpto

***********
table dpto año [fw=factorpob],c(mean pobre) row
table dpto año if (dpto==11 | dpto==18 | dpto==15) [fw=factorpob],c(mean pobre)

*pobre extremo
gen pobre_ext=(pobreza==1) //genera dummys en función de la condición
replace pobre_ext=pobre_ext*100

table dpto año [fw=factorpob],c(mean pobre_ext) row

*Indicadores de pobreza (incidencia, brecha y severidad)

sepov gpcm [w=factorpob], povline(linea) psu(conglome) strata(estrato)
sepov gpcm [w=factorpob], povline(linea) psu(conglome) strata(estrato) by(area)

*****
cumul gpcm, gen(gpcm_c)
twoway scatter gpcm_c gpcm, ytitle("Distribución acumulada del gasto total mensual per cápita") xtitle("Gasto total mensual per cápita") title("CDF del gasto total mensual per cápita") subtitle("Ejercicio 1.3e") saving(cdf1, replace)

graph use cdf1

********* Indicadores de desigualdad
*ssc install clorenz

*Coeficiente de Gini
clorenz gpcm, hweight(factorpob) hgroup(año) 

preserve
keep if año==2019
clorenz gpcm, hweight(factorpob) hgroup(area) 
restore

preserve
keep if año==2019
clorenz ingpc, hweight(factorpob) hgroup(area) 
restore

inequal7 gpcm [fw=factorpob]
inequal7 gpcm [fw=factorpob] if area==1
inequal7 gpcm [fw=factorpob] if area==2

inequal7 ingpc [fw=factorpob]

******************
*ssc instal ineqdeco
ineqdeco gpcm if gpcm>0 [fw=factorpob] 
ineqdeco ingpc if ingpc>0 [fw=factorpob] 

