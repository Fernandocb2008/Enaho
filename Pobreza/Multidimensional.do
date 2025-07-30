***Cálculo de la pobreza multidimensional

*******Pregunta 1: 
cd "C:\ENAHO con Stata\Bases"

clear all

global year "2012"
global year2 "2019"

***Pregunta 1
use sumaria-$year, clear
append using sumaria-$year2

ren aÑo año

* Factor de expansión de la población
gen facpob=factor07*mieperho

*******Pregunta 2: 
gen gastopc=gashog2d/(12*mieperho)

* Variables dummy para identificar al POBRE  O NO POBRE
tab pobreza, gen(pobre)

gen pobre=1 if pobre1==1 | pobre2==1
replace pobre=0 if pobre3==1

keep año conglome vivienda hogar estrato ubigeo dominio facpob pobreza pobre linea linpe gastopc factor07
save sumaria-multidi, replace

*********pregunta 3: 
// escolaridad familiar 
use "enaho01a-$year-300.dta", clear
append using enaho01a-$year2-300
ren aÑo año

keep if p204==1  //me quedo con los miembros del hogar

* tiene como grado de instrucción primaria completa o menos.
gen educ_p=1 if (p301a==1 | p301a==2 | p301a==3 | p301a==4) 
replace educ_p=0 if educ_p==.

* el jefe del hogar tiene como grado de instrucción primaria completa o menos.
gen educjh=1 if educ_p==1 & p203==1
replace educjh=0 if educjh==.
* dar el valor para cada persona del hogar
bys año conglome vivienda hogar: egen educa=sum(educjh)

keep año conglome vivienda hogar educa 
collapse (first) educa, by(año conglome vivienda hogar)
*duplicates drop conglome vivienda hoga,force
save "educacion-a.dta", replace

// matrícula escolar
use "enaho01a-$year-300.dta", clear
append using enaho01a-$year2-300
ren aÑo año

keep if p204==1
* el hogar en donde vive tiene al menos un niño en edad escolar (6 y 18 años) que no está matriculado en la educación básica regular a pesar de no haber terminado la secundaria.
destring mes, replace
gen escol=0
replace escol=1 if p306==2 &(p208a>=6 & p208a<=18) & p301a<=5  //tomar en 

* dar el valor para cada persona del hogar
bys año conglome vivienda hogar: egen escolar=sum(escol)
* dar valor "1" para cuando aparece 1 a más
gen escolar_h=1 if escolar>=1
replace escolar_h=0 if escolar==0

keep año conglome vivienda hogar mes escolar_h
collapse (first) escolar_h,by(año conglome vivienda hogar)
save "educacion-b.dta", replace

*******pregunta 4: 
use "enaho01a-$year-400.dta", clear
append using enaho01a-$year2-400
ren aÑo año

keep if p204==1

// asistencia a centro de salud
* ante una molestia, enfermedad o accidente no es capaz de acceder a los servicios de la salud
* porque: no tiene dinero, el centro de salud se encuentra muy lejos o no tiene seguro de salud.

gen salud_2=0
replace  salud_2=1 if  p4091==1 | p4092==1 | p4097==1

* dar el valor para cada persona del hogar
bys año conglome vivienda hogar: egen salud_3=sum(salud_2)

* dar valor "1" para cuando aparece 1 a más
gen salud=1 if salud_3>=1
replace salud=0 if salud_3==0

keep año conglome vivienda hogar salud
collapse (first) salud,by(año conglome vivienda hogar)
save "salud.dta", replace

**********pregunta 5:
use "enaho01-$year-100.dta", clear
append using enaho01-$year2-100,force
ren aÑo año

keep if result==1 | result==2   //resultado final de la encuesta, si está completa o incompleta

* no tiene electricidad en su vivienda
gen luz=0
replace luz=1 if p1121==0

* sin agua potable
gen aguap=0
replace aguap=1 if p110==7 | p110==6 |p110==5 | p110==4

* no tiene desague con conexión a red pública
gen sanea=0
replace sanea=1 if p111==2| p111==3| p111==4 | p111==5 | p111==6 | p111==7 | p111==8 // sin baño propio

* el piso de su vivienda está sucio, tiene arena o estiercol (vivienda con piso de tierra)
bys año conglome vivienda: egen p103_r=min(p103)

gen piso=0
replace piso=1 if p103_r==7 | p103_r==6 

* usa generalmente carbón o leña para cocinar (hogar usa combustible contaminante para cocinar)
gen combus=0
replace combus=1 if p113a==5 | p113a==6 | p113a==7 | p113a==. // incluye "otros" y missing 

keep año conglome vivienda hogar luz aguap sanea piso combus
save "cv.dta", replace

*******pregunta 6: 
********* las variables calculadas así como las preguntas utilizadas se juntan con la base sumaria ********************

use "sumaria-multidi.dta", clear
merge 1:1 conglome vivienda hogar using "cv.dta"
rename _m merge_1
merge 1:1 conglome vivienda hogar using "educacion-a.dta"
rename _m merge_2
merge 1:1 conglome vivienda hogar using "salud.dta"
rename _m merge_3
merge 1:1 conglome vivienda hogar using "educacion-b.dta"
rename _m merge_4
save "pm.dta", replace

********************** cálculo de la pobreza multidimensional ******************************
use "pm.dta", clear
destring año, replace

* calculo de porcentajes
svyset conglome [pw=facpob], strata(estrato)
svy: tab educa
svy: tab escolar_h
svy: tab salud
svy: tab luz
svy: tab aguap
svy: tab sanea
svy: tab piso
svy: tab combus

label variable educa "educación del jefe del hogar es primaria o menos"
label variable escolar_h "niños en edad escolar no matriculados en educación básica"
label variable salud "ante una molestia, enfermedad o accidente no accede a servicio de salud"
label variable luz "no tiene electricidad en su vivienda"
label variable aguap "no tiene agua potable"
label variable sanea "no tiene desag¸e con conexión pública"
label variable piso "piso de la vivienda es de tierra"
label variable combus "usa generalmente carbûn o leña para cocinar"

// el índice se construye ponderando cada componente

gen pm=(educa*(1/6))+ (escolar_h*(1/6))+ (salud*(1/3))+ (luz*(1/15))+ (aguap*(1/15))+ (sanea*(1/15))+ (piso*(1/15))+ (combus*(1/15))

label variable pm "índice de pobreza multidimensional"

// si el pm es mayor a 0.33, la persona se considera pobre multidimensional

gen pobre_m=1 if pm>0.33
replace pobre_m=0 if pm<=0.33
label variable pobre_m "indicador de pobre y no pobre multidimensional"
label define pobre_m 0 "no es pobre muldimensional" 1 "pobre multidimensional"
label values pobre_m pobre_m

svyset conglome [pw=facpob], strata(estrato)
svy: tab pobre_m año,col
svy: tab pobre año,col

************pregunta 7:

*ambito urbano y rural
gen area=1 if estrato>=1 & estrato<=5
replace area=2 if estrato>=6 & estrato<=8
label define area 1"urbano" 2"rural"
label values area area
label variable area "area urbana o rural"

svyset conglome [pw=facpob], strata(estrato)
svy: tab educa area if año==2019,col
svy: tab escolar_h area if año==2019,col
svy: tab salud area if año==2019,col
svy: tab luz area if año==2019,col
svy: tab aguap area if año==2019,col
svy: tab sanea area if año==2019,col
svy: tab piso area if año==2019,col
svy: tab combus area if año==2019,col

svy: tab pobre_m area if año==2012, col
svy: tab pobre area if año==2012, col
svy: tab pobre_m area if año==2019, col
svy: tab pobre area if año==2019, col

*departamento
gen dpto=substr(ubigeo,1, 2)
destring dpto, replace

lab def dpto 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" 8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
lab val dpto dpto

svy: tab dpto pobre_m if año==2019,row

svy: tab dpto pobre_m if año==2012,row

ssc install tabout
tabout  dpto pobre_m if año==2012 [iw = facpob] using tablas_enaho.xls,replace  c(freq row) f(0c 1p)

* region natural
recode dominio (1/3=1) (4/6=2) (7=3) (8=4), gen(reg_nat)
label define reg_nat 1"costa" 2"sierra" 3"selva" 4"lima_met"
label values reg_nat reg_nat

* dominio geográfico urbano y rural
gen dom_geo=1 if reg_nat==4
replace dom_geo=2 if reg_nat==1 & area==1
replace dom_geo=3 if reg_nat==1 & area==2
replace dom_geo=4 if reg_nat==2 & area==1
replace dom_geo=5 if reg_nat==2 & area==2
replace dom_geo=6 if reg_nat==3 & area==1
replace dom_geo=7 if reg_nat==3 & area==2
label define dom_geo 1"lima metropolitana" 2"costa urbana" 3"costa rural" 4"sierra urbana" 5"sierra rural" 6"selva urbana" 7"selva rural"
label values dom_geo dom_geo

***********pregunta 8 y 9: 
**me falta la variable de trabajo
*use "enaho01-$year-200.dta", clear

*logit pobre_m educa escolar sexo edad trabajo luz aguap sanea piso combus gastopc area,robust 

*logit pobre_m educa escolar sexo edad luz aguap sanea piso combus gastopc area,robust 

*logit pobre educa escolar sexo edad luz aguap sanea piso combus gastopc area,robust 

***************************** // Mapas //**************************

*Primero: preparamos la base de datos de la Enaho

collapse (mean) pm  linea gastopc  pobre pobre_m, by(dpto año)
label var pobre_m "Pobreza Multidimensional"
label var pobre "Pobreza Monetaria"
save "pobreza_mm.dta", replace

*Segundo: convertimos los "shapefile" a base de datos de Stata 
shp2dta using BAS_LIM_DEPARTAMENTO, database(data_depar) coordinates(coord_depar) genid(id_cert) gencentroids(coord) replace 

*Tercero: trabajamos la base de datos del departamento
use data_depar, clear
gen dpto=id_cert //Para crear las etiquetas del departamento

*Dpto
lab def dpto 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" 8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
lab val dpto dpto

*Cuarto: unimos ambas bases, ya que la usaremos para el gráfico del mapa
merge 1:m dpto using pobreza_mm.dta
drop _merge

*Quinto: damos formato a las variables
replace pobre = pobre*100
replace pobre_m = pobre_m*100
format %6.0g pobre
format %6.0g pobre_m

*Mapas (mucho más elaborados)
spmap pobre if año==2019 using coord_depar, id (id_cert) fcolor(Blues) ///
clmethod(custom) clbreaks(0 10 20 30 40 55) oc(black) os(vvvthick_list) mop(dash) ///
title("Pobreza Monetaria, Perú 2019") ///
legend(on) clnumber(5) legend(title("Niveles de Pobreza Monetaria", size(*0.5))) ///
name(monetaria_2019, replace) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7))

*Mapa pobreza monetaria (2012-2019)
spmap pobre if año==2012 using coord_depar, id (id_cert) fcolor(Blues) ///
clmethod(custom) clbreaks(0 10 20 30 40 55) oc(black) os(vvvthick_list) mop(dash) ///
title("Pobreza Monetaria, Perú 2012") ///
legend(on) clnumber(6) legend(title("Niveles de Pobreza Monetaria", size(*0.5))) ///
name(monetaria_2012, replace) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7))

graph combine monetaria_2012 monetaria_2019

*Mapa pobreza multidimensional (2012-2019)
spmap pobre_m if año==2012 using coord_depar, id (id_cert) fcolor(Blues) ///
clmethod(custom) clbreaks(0 10 20 30 40 62) oc(black) os(vvvthick_list) mop(dash) ///
title("Pobreza Multidimensional, Perú 2014") ///
legend(on) clnumber(6) legend(title("Niveles de Pobreza Multidimensional", size(*0.5))) ///
name(multidimensional_2012, replace) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7))

spmap pobre_m if año==2019 using coord_depar, id (id_cert) fcolor(Blues) ///
clmethod(custom) clbreaks(0 10 20 30 40 62) oc(black) os(vvvthick_list) mop(dash) ///
title("Pobreza Multidimensional, Perú 2019") ///
legend(on) clnumber(6) legend(title("Niveles de Pobreza Multidimensional", size(*0.5))) ///
name(multidimensional_2019, replace) ///
label(label(NOMBDEP) xcoord(x_coord) ycoord(y_coord) size(*0.7))

graph combine multidimensional_2012 multidimensional_2019 

graph combine monetaria_2019 multidimensional_2019
