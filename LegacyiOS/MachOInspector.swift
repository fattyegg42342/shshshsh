import Foundation

struct MachOResult { var arm32=false; var arm64=false; var encrypted=false; var arch="unknown" }

struct MachOInspector {
    static func inspect(_ url:URL)throws->MachOResult {
        let d=try Data(contentsOf:url,options:.mappedIfSafe)
        if d.count<28{throw MachOError.invalid}
        let be=read(d,0,false)
        var r=MachOResult()
        if be==0xcafebabe || be==0xcafebabf {
            let is64=be==0xcafebabf
            let count=Int(read(d,4,false))
            let step=is64 ? 32:20
            for i in 0..<count {
                let p=8+i*step
                if p+step>d.count{throw MachOError.invalid}
                let off=Int(is64 ? read64(d,p+8,false):UInt64(read(d,p+8,false)))
                merge(&r,try thin(d,off))
            }
        } else {
            r=try thin(d,0)
        }
        var a:[String]=[]
        if r.arm32{a.append("ARM32")}
        if r.arm64{a.append("ARM64")}
        r.arch=a.isEmpty ? "unknown":a.joined(separator:" + ")
        return r
    }

    static func thin(_ d:Data,_ o:Int)throws->MachOResult {
        if o+28>d.count{throw MachOError.invalid}
        let magic=read(d,o,true)
        let is64:Bool
        if magic==0xfeedface{is64=false}
        else if magic==0xfeedfacf{is64=true}
        else{throw MachOError.invalid}
        let cpu=read(d,o+4,true)
        let n=Int(read(d,o+16,true))
        var p=o+(is64 ? 32:28)
        var r=MachOResult()
        r.arm32=cpu==12
        r.arm64=cpu==0x0100000c
        for _ in 0..<n {
            if p+8>d.count{throw MachOError.invalid}
            let cmd=read(d,p,true)
            let size=Int(read(d,p+4,true))
            if size<8 || p+size>d.count{throw MachOError.invalid}
            if (cmd==0x21 || cmd==0x2c) && size>=20 {
                if read(d,p+16,true) != 0 {r.encrypted=true}
            }
            p+=size
        }
        return r
    }

    static func merge(_ a:inout MachOResult,_ b:MachOResult){
        a.arm32 = a.arm32 || b.arm32
        a.arm64 = a.arm64 || b.arm64
        a.encrypted = a.encrypted || b.encrypted
    }
    static func read(_ d:Data,_ o:Int,_ little:Bool)->UInt32 {
        let b=d[o..<o+4].map{UInt32($0)}
        return little ? b[0]|b[1]<<8|b[2]<<16|b[3]<<24 : b[3]|b[2]<<8|b[1]<<16|b[0]<<24
    }
    static func read64(_ d:Data,_ o:Int,_ little:Bool)->UInt64 {
        let lo=UInt64(read(d,o,little)),hi=UInt64(read(d,o+4,little))
        return little ? lo|(hi<<32):(lo<<32)|hi
    }
}

enum MachOError:Error { case invalid }
