*Nota para calculo de indicadores sociales filtrar miembros del hogar
*Para tener mejores estimacionaes de población absoluta usar residente habitual

********* Tasa de Analfabetismo: personas de 15 a más que no saben leer ni escribir 

use enaho01a-2019-300, clear
drop if codinfor=="00"
gen factor2=round(factora07,2)

*Región o departamento
gen ubigeo1=substr(ubigeo,1,2) //Extracción de código de región
gen region=real(ubigeo1) //Conversión a dato numérico
drop ubigeo1

lab def region ///
1 "Amazonas" ///
2 "Áncash" ///
3 "Apurímac" ///
4 "Arequipa" ///
5 "Ayacucho" ///
6 "Cajamarca" ///
7 "Callao" ///
8 "Cusco" ///
9 "Huancavelica" ///
10 "Huánuco" ///
11 "Ica" ///
12 "Junín" ///
13 "La Libertad" ///
14 "Lambayeque" ///
15 "Lima" ///
16 "Loreto" ///
17 "Madre de Dios" ///
18 "Moquegua" ///
19 "Pasco" ///
20 "Piura" ///
21 "Puno" ///
22 "San Martin" ///
23 "Tacna" ///
24 "Tumbes" ///
25 "Ucayali"
label val region region

*Metodo 1: Calculo de indicador
*Me quedo con el techo de población para el indicador
keep if (p204==1 & p208a>=15) //miembros del hogar y de 15 a más años

gen analfabeto=0
replace analfabeto=100 if p302==2 //coloco 100 para no trabajar con decimales pero se puede poner 1 y en el excel se coloca el formato %

lab def  analfabeto 0 "Alfabeto" 100 "Analfabeto" 
lab val analfabeto analfabeto
tab analfabeto

table p207 [pw=factora07],c(mean analfabeto) row
table p207 [fw=factor2],c(mean analfabeto) row

tabstat analfabeto [fw=factor2], by(p207)

*Intervalos de confianza
*svyset conglome [pweight=factora07], strata(estrato)
svyset [pweight = factora07], psu(conglome) strata(estrato)
svy: mean analfabeto
svy: mean analfabeto,  over(p207)
svy: mean analfabeto,  over(region)

*Diferencia de medias
svy: mean analfabeto,  over(p207) 
lincom analfabeto@2.p207 - analfabeto@1.p207 
*lincom [analfabeto]mujer - [analfabeto]hombre //version hasta stata15

******** // Tabulados // ***
*Nivel educativo población de 3 a más años
use enaho01a-2019-300, clear
drop if codinfor=="00"
drop if p301a==.
gen factor2=round(factora07,2)
keep if p204==1

*Nivel educativo
tabulate p301a,m
tab p301a [fw=factor2]

*Indicadores a partir de preguntas
tab p301a, gen(niv_edu)

******** // Tasa total o bruta de asistencia 3 a 5 años //
use enaho01a-2018-300, clear
drop if codinfor=="00" //siempre se excluyen (valores perdidos)
drop if p301a==.
keep if p204==1 //Para indicadores sociales y pobreza se trabaja con miembros de hogar

gen factor2=round(factora07,2)

*Área geográfica
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

*Merge con cap. 400 (1:1 porque el merge es a nivel de personas)
merge 1:1 aÑo mes conglome vivienda hogar codperso using enaho01a-2018-400
drop if _merge==2
drop _merge

destring aÑo, replace
destring mes, replace

*Edad al mes de marzo
gen marzo=3
gen edadmarzo=aÑo-p400a3   //2018mar  -2017dic
replace edadmarzo=edadmarzo-1 if marzo<p400a2

sort edadmarzo
br mes edadmarzo p208a p400a2 p400a3 p307 p308a p204 p301a

*recuperando casos que no tienen año de nacimiento en cap400
replace edadmarzo=p208a if edadmarzo==.

**Método 2: Cálculo de indicador (sin eliminar filas)
*Identificas tu techo de poblacion con 0 
gen tta_3a5=0 if (mes>=4 & (edadmarzo>=3 & edadmarzo<=5)) 
replace tta_3a5=100 if (tta_3a5==0 & p307==1) 

lab def tta_3a5 0 "No asiste" 100 "Tasa de asistencia"
lab val tta_3a5 tta_3a5

table p207 [pw=factora07],c(mean tta_3a5) row format(%3.1f)
tabstat tta_3a5 [fw=factor2], by(p207) format(%3.1f)

*export table 

******** // Tasa total de asistencia 6 a 11 años //
gen tta_6a11=0 if (mes>=4 & (edadmarzo>=6 & edadmarzo<=11)) 
replace tta_6a11=100 if (tta_6a11==0 & p307==1) 

lab def tta_6a11 0 "No asiste" 100 "Tasa de asistencia"
lab val tta_6a11 tta_6a11

table p207 [pw=factora07],c(mean tta_6a11) row format(%3.1f)
tabstat tta_6a11 [fw=factor2], by(p207) format(%3.1f)

svyset [pweight = factora07], psu(conglome) strata(estrato)
svy: mean tta_6a11,over(p207)
lincom tta_6a11@2.p207 - tta_6a11@1.p207 


******* // TASA NETA DE ASISTENCIA A INICIAL //*********.

*MINEDU
gen tna_ini = 0 if (mes>=4 & (edadmarzo>= 3 & edadmarzo<= 5)) 
replace tna_ini = 1 if (tna_ini == 0) & (p307==1 & p308a==1)

lab def tna_ini 0 "No asiste" 1 "Tasa asist neta inicial"
lab val tna_ini tna_ini

replace tna_ini=tna_ini*100
table p207 [fw=factor2],c(mean tna_ini) row format(%3.1f)
table p207 [pw=factora07],c(mean tna_ini) row format(%3.1f)

*****INEI
gen tna_ini2=0 if (mes>=4 & p204==1 & (p208a>=3 & p208a<=5))
replace tna_ini2 = 1 if (tna_ini2==0 & p307==1 & p308a==1) 

lab def tna_ini2 0 "No asiste" 1 "Tasa de asistencia"
lab val tna_ini2 tna_ini2
replace tna_ini2=tna_ini2*100

table area [pw=factora07],c(mean tna_ini2) row format(%3.2f)
tabstat tna_ini2 [fw=factor2],by(area) format(%3.2f)

***********ASISTENCIA NETA PRIMARIA*****************.
gen tna_prim = 0 if (mes>=4 & (edadmarzo>= 6 & edadmarzo<= 11)) 
replace tna_prim = 1 if (tna_prim ==0) & (p307==1 & p308a==2) 

lab def tna_prim 0 "No asiste" 1 "Tasa asist neta prim"
lab val tna_prim tna_prim

replace tna_prim=tna_prim*100
table p207 [pw=factora07],c(mean tna_prim) row format(%3.2f)
tabstat tna_prim [fw=factor2],by(p207) format(%3.2f)

svyset [pweight = factora07], psu(conglome) strata(estrato)
svy: mean tna_prim
svy: mean tna_prim,  over(p207)

***********ASISTENCIA NETA SECUNDARIA****************.
gen tna_sec= 0 if (mes>=4 & (edadmarzo>=12 & edadmarzo<=16)) 
replace tna_sec= 100 if (tna_sec==0 & (p307==1 & p308a==3)) 

lab def tna_sec 0 "No asiste" 100 "Tasa asist neta prim"
lab val tna_sec tna_sec

table p207 [pw=factora07],c(mean tna_sec) row format (%3.1f)

*********** TASA TOTAL DE MATRICULA 6 a 11 años
gen mattot_6a11=0 if (mes>=4 & (edadmarzo>=6 & edadmarzo<=11)) 
replace mattot_6a11=100 if (mattot_6a11==0 & p306==1) 

table p207 [pw=factora07],c(mean mattot_6a11) row format(%3.1f)

********* Tasa neta matricula 6 a 11
gen matnet_6a11=0 if (mes>=4 & (edadmarzo>=6 & edadmarzo<=11)) 
replace matnet_6a11=100 if (matnet_6a11==0 & p306==1 & p308a==2) 

table p207 [pw=factora07],c(mean matnet_6a11) row format(%3.1f)

******** Transición a educación superior
gen transisup=0 if ((p304a==3 & p304b==5) & p305==1 & mes>=4)  //el techo o denominador son los estudiantes que aprobaron el 5to de secundaria el año pasado
replace transisup=100 if (transisup==0 & p307==1 & p308a>3 & p308b==1) //el numerador son los estudiantes que asisten a educación superior

lab def transisup 100 "Transita de secundaria a superior" 0 "No transita"
lab val transisup transisup

table p207 [pw=factora07],c(mean transisup) row format(%3.1f)

******* Indicador Años promedio de educación o escolaridad (25 a 64 años)

*grupos de edad
recode p208a (0/24=1 "Hasta 24 años") (25/64=2 "De 25 a 64 años") (65/max=3 "De 65 a más años"), gen (g_edad)

*Indicador
gen año_est=0 if p301a==1
replace año_est=0 if p301a==2
replace año_est=1 if p301a==3 & p301b==0
replace año_est=2 if p301a==3 & p301b==1
replace año_est=3 if p301a==3 & p301b==2
replace año_est=4 if p301a==3 & p301b==3
replace año_est=5 if p301a==3 & p301b==4
replace año_est=5 if p301a==3 & p301b==5
replace año_est=6 if p301a==4 & p301b==5
replace año_est=6 if p301a==4 & p301b==6
replace año_est=7 if p301a==5 & p301b==1
replace año_est=8 if p301a==5 & p301b==2
replace año_est=9 if p301a==5 & p301b==3
replace año_est=10 if p301a==5 & p301b==4
replace año_est=10 if p301a==5 & p301b==5
replace año_est=11 if p301a==6 & p301b==5
replace año_est=11 if p301a==6 & p301b==6
replace año_est=12 if p301a==7 & p301b==1
replace año_est=13 if p301a==7 & p301b==2
replace año_est=14 if p301a==7 & p301b==3
replace año_est=14 if p301a==7 & p301b==4
replace año_est=14 if p301a==8 & p301b==3
replace año_est=15 if p301a==8 & p301b==4
replace año_est=16 if p301a==8 & p301b==5
replace año_est=12 if p301a==9 & p301b==1
replace año_est=13 if p301a==9 & p301b==2
replace año_est=14 if p301a==9 & p301b==3
replace año_est=15 if p301a==9 & p301b==4
replace año_est=15 if p301a==9 & p301b==5
replace año_est=15 if p301a==9 & p301b==6
replace año_est=15 if p301a==10 & p301b==4
replace año_est=16 if p301a==10 & p301b==5
replace año_est=16 if p301a==10 & p301b==6
replace año_est=16 if p301a==10 & p301b==7
replace año_est=16 if p301a==11 & p301b==1
replace año_est=16 if p301a==11 & p301b==2
replace año_est=1 if p301a==3 & p301c==1
replace año_est=2 if p301a==3 & p301c==2
replace año_est=3 if p301a==3 & p301c==3
replace año_est=4 if p301a==3 & p301c==4
replace año_est=5 if p301a==3 & p301c==5
replace año_est=6 if p301a==4 & p301c==5
replace año_est=6 if p301a==4 & p301c==6
replace año_est=p301b if p301a==12 & p301b!=0
replace año_est=p301c if p301a==12 & año_est==.

*Indicador solo respecto a poblacion de 25 a 64 años (g_edad==2)
tabstat año_est [fw=factor2] if g_edad==2, by(p207)
table p207 [pw=factora07] if g_edad==2,c(mean año_est) row format(%3.1f)

******** Deserción escolar en secundaria, refleja los estudiantes con secundaria incompleta que no están matriculados el año presente (respecto a pob de 13 a 19 años)

gen desersec=0 if (mes>= 4 & edadmarzo>= 13 & edadmarzo<=19 & p301a==5) 
replace desersec = 100 if (desersec==0 & p306== 2)

lab def desersec 100 "Deserción secundaria" 0 "No deserción"
lab val desersec desersec

tabstat desersec [fw=factor2], by(p207)
table p207 [pw=factora07],c(mean desersec) row format(%3.1f)

**********Rezago escolar, refleja los chicos que están en un grado que no les corresponde estar según su edad

*ultimo nivel aprobado
tab edad p301a,m row

*matriculado eño pasado
tab edad p303 if p301a<=5,m row
tab edad p303 if edad>=13 & edad<=17,m row

table edad  p303 area,row col 

*desaprobo el año pasado
tab edad p305  if p303==1,m row 

*matriculado este año
tab edad p306 if p301a<=5 & edad>=12 & edad<=17,m row

*Razon
tab p313 if p306==2 &  p301a<=5,m 

*no matriculado este año ni el anterior
gen nomatri=(p303==2 & p306==2)

tab edad nomatri [fw=factor2] if p301a<=5 & edad>=12 & edad<=17,m row
tab edad nomatri [fw=factor2] if p301a<=5 & edad>=14 & edad<=17,m row

*rezago escolar
gen edad_norma=6 if p306==1 & p308a==2 & p308c==1
replace edad_norma=7 if p306==1 & p308a==2 & p308c==2
replace edad_norma=8 if p306==1 & p308a==2 & p308c==3
replace edad_norma=9 if p306==1 & p308a==2 & p308c==4
replace edad_norma=10 if p306==1 & p308a==2 & p308c==5
replace edad_norma=11 if p306==1 & p308a==2 & p308c==6
replace edad_norma=12 if p306==1 & p308a==3 & p308b==1
replace edad_norma=13 if p306==1 & p308a==3 & p308b==2
replace edad_norma=14 if p306==1 & p308a==3 & p308b==3
replace edad_norma=15 if p306==1 & p308a==3 & p308b==4
replace edad_norma=16 if p306==1 & p308a==3 & p308b==5

*Techo de población para el indicador (denominador)
keep if edadmarzo>=6 & edadmarzo<=16 & p306==1 //chicos de 6 a 16 años matriculados este año en alguna IE

*Calcular años de diferencia respecto a lo normado
gen años_dif=edadmarzo-edad_norma if p306==1 & p308a==2 & p308c==1
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==2 & p308c==2 
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==2 & p308c==3 
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==2 & p308c==4 
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==2 & p308c==5 
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==2 & p308c==6
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==3 & p308b==1
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==3 & p308b==2
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==3 & p308b==3
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==3 & p308b==4
replace años_dif=edadmarzo-edad_norma if p306==1 & p308a==3 & p308b==5

gen rezago=1 if años_dif<0
replace rezago=2 if años_dif==0
replace rezago=3 if años_dif==1
replace rezago=4 if años_dif>1
lab def rezago 1 "Adelanto" 2 "normal" 3 "rezago leve" 4 "rezago severo"
lab val rezago rezago

*Este indicador tiene varias categorías según el nivel de rezago
*A nivel total el 10.21% tiene rezago leve y el 5.39% tiene rezago severo
tab rezago
tab rezago area [fw=factor2],col
