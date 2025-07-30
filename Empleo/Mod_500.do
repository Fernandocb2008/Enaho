**** BASE 500 ********
use enaho01a-2018-500, clear

*merge con cap. 300
merge 1:1 aÑo conglome vivienda hogar codperso using enaho01a-2018-300
drop if _merge==2
drop _merge 

*RESIDENTE HABITUAL DEL HOGAR
*************
drop if codinfor=="00"
gen residente=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
keep if (residente==1) //siempre se trabaja con residentes habituales en esta base

*AREA
******
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

*AMBITO GEOGRAFICO*.
**********************
gen areag=1 if (dominio==8)  
replace areag=2 if ((dominio >= 1 & dominio <= 7) & (estrato  >= 1 & estrato <= 5)) 
replace areag=3 if ((dominio >= 1 & dominio <= 7) & (estrato  >= 6 & estrato <= 8))  
lab def areag 1 "Lima Metropolitana" 2 "Resto Urbano" 3 "Rural"
lab val areag areag

*REGIÓN NATURAL 
**************
gen region=1 if dominio>=1 & dominio<=3 
replace region=1 if dominio==8
replace region=2 if dominio>=4 & dominio<=6 
replace region=3 if dominio==7 
label define region 1 "Costa" 2 "Sierra" 3 "Selva"

*DPTO
*******************.
gen dpto=substr(ubigeo,1, 2)
destring dpto, replace

lab def dpto 1 "AMAZONAS" 2 "ANCASH" 3 "APURIMAC" 4 "AREQUIPA" 5 "AYACUCHO" 6 "CAJAMARCA" 7 "CALLAO" 8 "CUSCO" 9 "HUANCAVELICA" 10 "HUANUCO" 11 "ICA" 12 "JUNIN" 13 "LA LIBERTAD" 14 "LAMBAYEQUE" 15 "LIMA" 16 "LORETO" 17 "MADRE DE DIOS" 18 "MOQUEGUA" 19 "PASCO" 20 "PIURA" 21 "PUNO" 22 "SAN MARTIN" 23 "TACNA" 24 "TUMBES" 25 "UCAYALI"
lab val dpto dpto

*GRUPOS DE EDAD
***************************
recode p208a (14/17=1) (18/29=2) (30/45=3) (46/60=4) (61/99=5), gen (g_edad)
lab def g_edad 1 "De 14 a 17 años" 2 "18 a 29 años" 3 "30 a 45 años" 4 "46 a 60 años" 5 "Más de 60 años"
lab val g_edad g_edad

*NIVEL EDUCATIVO
*************
gen n_edu=1 if p301a==1 
replace n_edu=2 if (p301a==2 | p301a==3) 
replace n_edu=3 if (p301a==4 | p301a==5 | p301a==12)
replace n_edu=4 if p301a==6 
replace n_edu=5 if (p301a>=7 & p301a<=11)  
replace n_edu=1 if p301a==. 

lab def n_edu 1 "Sin instrucción" 2 "Primaria incompleta" 3 "Primaria" 4 "Secundaria completa"  5 "Superior"
lab val n_edu n_edu

**TAMAÑO DE EMPRESA
*******************************
recode p512b (1/10=1)  (11/50=2)  (51/9998=3), gen (t_emp)
replace t_emp=4 if (codinfor ~= "00" & p512b==.)

lab def t_emp 1 "De 1 a 10 trabajadores" 2 "De 11 a 50 trabajadores" ///
3 "De 51 y más" 4 "NEP"
lab val t_emp t_emp

*************************** // INDICADORES //********************

*PEA
***********.
tab ocu500,m

recode ocu500 (1/2=1)  (3/4=2), gen (PET)
label def PET 1 "PEA" 2 "NO_PEA"
lab val PET PET

*Condicion de actividad*
****************************

recode ocu500 (1=1)(2=2)(3/4=3), gen (c_act)
lab def c_act 1 "Ocupado" 2 "Desocupado" 3 "No PEA"

lab val c_act c_act

**CATEGORIA DE OCUPACION
**************************
recode p507 (1=1) (2=3) (5=4) (7=6) (3/4=2) (6=5),gen(c_ocupac)

label def c_ocupac 1 "Empleador/Patrono" 2 "Dependiente" 3 "Independiente" 4 "Familiar no remunerado" 5 "Trabajador del hogar" 6 "Otro"
lab val c_ocupac c_ocupac

lab def p507_c 1 "Empleador" 2 "Independiente" 3 "Empleado" 4 "Obrero" 5 "familiar no remunerado" 6 "Trabajador del hogar" 7 "Otro"
lab val p507 p507_c

**ramas de actividad
**************************
gen ciuu=p506r4
tostring ciuu,replace
gen tam=length(ciuu)
replace tam=. if tam==1
replace ciuu="0"+ ciuu if tam==3   
gen ciuu2dig=substr(ciuu,1,2)
destring ciuu2dig, replace

recode ciuu2dig (1/3 =1) (5/9 =2) (10/33 =3) (35=4) (36/39 =5) ///
(41/43 =6) (45/47 =7) (49/53 =8) (55/56 =9) (58/63 =10) (64/66 =11) ///
(68 =12) (69/75 =13) (77/82 =14) (84 =15) (85 =16)(86/88 =17) (90/93 =18) ///
(94/96 =19) (97/98 =20) (99 =21), gen(ciuu1dig)

*grandes ramas
recode ciuu1dig (1/2=1) (3=2) (4=6) (5=6) (6=3) (7=4) (8=5) (10=5) (9=6) (11/21=6), gen(ramas)

lab def ramas ///
1 "Agricultura/Pesca/Minería" ///
2 "Manufactura" ///
3 "Construcción" ///
4 "Comercio" ///
5 "Transportes y Comunicaciones" ///
6 "Otros Servicios"
lab val ramas ramas

*sector
recode ramas (1=1) (2=2) (3=4) (4/6=3), gen(sector)
lab def sector 1 "Primario" 2 "Manufactura" 3 "Terciario" 4 "Construcción"
lab val sector sector

*****cuadros
gen factor2=round(fac500a,2)

*Para estimar población se usa pw y el factor de la base sin redondear
tabulate PET [fw=factor2]
table PET [pw=fac500a], format (%10.0fc) row
display  17462752/24142315*100 //el indicador es similar si se usa pw o fw

table PET, c(sum fac500a) format (%10.0fc) row

table PET area [pw=fac500a], format (%10.0fc) row col

tab PET [iw=fac500a]

tab c_act [iw=fac500a]

*Tasa de desempleo
tab c_act [iw=fac500a] if PET==1 //PET 1 es la PEA

tab c_act area [iw=fac500a] if PET==1,col

tab p507 area [fw=factor2] if ocu500==1,col

*nacional
tab rama area [iw=fac500a] if ocu500==1,col
tab rama p507 [iw=fac500a] if ocu500==1,row

************************. 
*Ingreso Por Trabajo
*************************.   
*i524a1: ingreso total en ocupación principal dependiente
*d529t: Pago en especie estimado
*i530a: ingresos en ocup. principal independiente
*d536: valor de productos para autoconsumo
*i538a1 d540t i541a d543: lo mismo pero para act. secundaria
*d544t: ingresos extraordinarios

*total
egen ingtrab_año=rsum(i524a1 d529t i530a d536 i538a1 d540t i541a d543 d544t)
gen ingtrab=ingtrab_año/12

*Filtrar los ingresos mayores a 0

*Ingresos por sexo
table p207 [pw=fac500a] if ingtrab>0, c(mean ingtrab) row

tabstat ingtrab [fw=factor2] if ingtrab>0, s(mean min p25 p50 p75 p95 max) by(p207)

*Ingresos por ramas
table ramas [pw=fac500a] if ingtrab>0, c(mean ingtrab) row

*Ingresos por nivel educativo
table n_edu [pw=fac500a] if ingtrab>0, c(mean ingtrab) row

***** INFORMALIDAD ********
tab ocupinf [iw=fac500a]

tab ocupinf area [iw=fac500a],col

tab  ramas ocupinf [iw=fac500a],row

************************************************************
                     * SUBEMPLEO
************************************************************

*Perceptores
gen percep=1 if (residente ==1 & p203!=8 &  p203!=9 & ingtrab>0 & ingtrab!=.) 

*ingtrab!=. es lo mismo !missing(ingtrab)

preserve
collapse (sum) percep, by(aÑo conglome vivienda hogar)
save perceptores, replace
restore

egen horaw1= rsum(i513t i518)
replace horaw1=i520 if (horaw1==0 & i520>0)

*Mintra
recode i513t i518 (.=0) if p519==1
gen horawt=i513t+i518 if p519==1
replace horawt=i520 if p519==2

br i513t i518 p519 p520 horawt horaw1

*********** En la Sumaria
preserve
use sumaria-2018,clear

gen facpob=factor07*mieperho

*Area
******
replace estrato =1 if dominio==8
recode estrato (1/5=1)(6/8=2), gen(area)
lab def area 1 "Urbano" 2 "Rural"
lab val area area

*crear dominio
gen dominio2=1 if (dominio>=1 & dominio<=3 & area==1) 
replace dominio2=2 if (dominio>=1 & dominio<=3 & area==2)
replace dominio2=3 if (dominio>=4 & dominio<=6 & area==1)
replace dominio2=4 if (dominio>=4 & dominio<=6 & area==2)
replace dominio2=5 if (dominio==7 & area==1)
replace dominio2=6 if (dominio==7 & area==2)
replace dominio2=7 if (dominio==8 & area==1)

lab def dominio2 1 "Costa urbana" 2 "Costa rural" 3 "Sierra urbana" 4 "Sierra rural" 5 "Selva urbana" 6 "Selva rural" 7 "Lima Metropolitana"
lab val dominio2 dominio2

*traer los perceptores
merge 1:1 aÑo conglome vivienda hogar using perceptores
drop if _merge==2
drop _merge

collapse (mean) linea mieperho percep [pw=facpob],by(aÑo dominio2)
gen imr=linea * mieperho / percep
keep imr aÑo dominio2
save base_imr,replace
restore //Regreso a base500

*************************

*genero domino2 en base500
gen dominio2=1 if (dominio>=1 & dominio<=3 & area==1) 
replace dominio2=2 if (dominio>=1 & dominio<=3 & area==2)
replace dominio2=3 if (dominio>=4 & dominio<=6 & area==1)
replace dominio2=4 if (dominio>=4 & dominio<=6 & area==2)
replace dominio2=5 if (dominio==7 & area==1)
replace dominio2=6 if (dominio==7 & area==2)
replace dominio2=7 if (dominio==8 & area==1)

*unir con IMR
merge m:1 aÑo dominio2 using base_imr,nogen

gen subempM=1 if (ocu500==1 & horawt<35 & (p521==1 & p521a==1)) 
replace subempM=2 if (ocu500==1 & ingtrab<imr & horawt<35 & (p521==1 & p521a==2)) 
replace subempM=2 if (ocu500==1 & ingtrab<imr & horawt<35 & (p521==2))
replace subempM=2 if (ocu500==1 & ingtrab<imr & horawt>=35 & !missing(horawt))
replace subempM=3 if (ocu500==1 & ingtrab>=imr & !missing(ingtrab) & horawt<35 & (p521==1 & p521a==2)) 
replace subempM=3 if (ocu500==1 & ingtrab>=imr & !missing(ingtrab) & horawt<35 & p521==2) 
replace subempM=3 if (ocu500==1 & ingtrab>=imr & !missing(ingtrab) & horawt>=35 & !missing(horawt))
replace subempM=3 if (ocu500==1 & horawt<35 & missing(p521) & missing(subempM) & ingtrab>imr & !missing(ingtrab)) 

replace subempM=4 if (ocu500==2) //desempleados 

replace subempM=1 if (ocu500==1 & horawt<35 & missing(p521) & missing(subempM) & ingtrab<imr)

lab var subempM "Subempleo_Ministerio"
lab def subempM 1 "Visible o por horas" 2 "Invisible o por ingresos" 3 "Adecuado" 4 "Desempleado"
lab val subempM subempM

*Solo urbana
table subempM [pw=fac500a] if PET==1,row format(%10.0fc) 
tab subempM [fw=factor2] if (ocu500== 1 | ocu500==2),m

*Solo urbana
table subempM [pw=fac500a] if (ocu500== 1 | ocu500==2) & area==1,row format(%10.0fc) 
tab subempM [fw=factor2] if (ocu500== 1 | ocu500==2) & area==1,m

*Solo Lima Metropolitana
table subempM [pw=fac500a] if (ocu500== 1 | ocu500==2) & dominio2==7,row format(%10.0fc) 
tab subempM [iw=fac500a] if (ocu500== 1 | ocu500==2) & dominio2==7,m

***********************************
          *Trabajo infantil
**************************************
use "enaho01-2015-200",clear  //Población
merge 1:1 aÑo conglome vivienda hogar codperso using enaho01a-2015-500
drop if _merge==2
drop _merge
drop if codinfor=="00" //missing

*Solo menores de 5 a 17 años
keep if p208a>=5 & p208a<=17 

*residente habitual para indicadores de empleo (estima mejor población absoluta)
gen residente=1 if ((p204==1 & p205==2) | (p204==2 & p206==1)) 
keep if (residente==1) 

**gen horas cap 500, 14 a 17 años
egen hw_1417=rsum(i513t i518)
*se usa i520 para los jovenes que vana regresar a trabajar
replace hw_1417=i520 if hw_1417==0 & ocu500==1

*gen factor
gen factor=facpob07 if p208a>=5 & p208a<=13
replace factor=fac500a if p208a>=14 & p208a<=17

***indicador ocupado
gen ocup=0
replace ocup=1 if ((p210==1 | (t211>=1 & t211<=7 | t211==12)) & p208a>=5 & p208a<=13) //niños
replace ocup=1 if ((hw_1417>=1 | ocu500==1) & p208a>=14 & p208a<=17) //adolescentes

*tablas
table ocup [pw=factor],row format(%12.0fc) //26.38 %
table ocup [pw=facpob07],row format(%12.0fc)

tab ocup [iw=factor],m

**horas_trab totales
gen horas_trab=hw_1417 if p208a>=14 & p208a<=17
replace horas_trab=p211d if p208a>=5 & p208a<=13
replace horas_trab=0 if horas_trab==. | horas_trab==999

***trab intensivo
gen trab_int=0
replace trab_int=1 if horas_trab>=24 & p208a>=5 & p208a<=13
replace trab_int=1 if horas_trab>=36 & p208a>=14 & p208a<=17
table trab_int [pw=factor],row format(%12.0f)
tab trab_int [iw=factor],m

***trab infantil
gen trab_inf=0
replace trab_inf=1 if ocup==1 & p208a>=5 & p208a<=11
replace trab_inf=1 if trab_int==1 & p208a>=12 & p208a<=17
table trab_inf [pw=factor],row format(%12.0f)
tab trab_inf [iw=factor],m

