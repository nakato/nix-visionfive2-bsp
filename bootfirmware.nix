{ dtc
, spl_tool
, stdenv
, uboot
, opensbi
, ubootTools
, writeText
, ...
}:
let
  vf2ubootits = writeText "vf2-uboot.its" ''
    /dts-v1/;
    
    / {
    	description = "U-boot-spl FIT image for JH7110 VisionFive2";
    	#address-cells = <2>;
    
    	images {
    		firmware {
    			description = "u-boot";
    			data = /incbin/("${opensbi}/share/opensbi/lp64/generic/firmware/fw_payload.bin");
    			type = "firmware";
    			arch = "riscv";
    			os = "u-boot";
    			load = <0x0 0x40000000>;
    			entry = <0x0 0x40000000>;
    			compression = "none";
    		};
    	};
    
    	configurations {
    		default = "config-1";
    
    		config-1 {
    			description = "U-boot-spl FIT config for JH7110 VisionFive2";
    			firmware = "firmware";
    		};
    	};
    };
  '';
in
stdenv.mkDerivation {
  name = "visionfive2 boot firmware";
  dontUnpack = true;
  buildInputs = [ dtc spl_tool ubootTools ];

  buildPhase = ''
    runHook preBuild

    cp ${uboot}/u-boot-spl.bin u-boot-spl.bin
    spl_tool -c -f u-boot-spl.bin 

    mkimage -f ${vf2ubootits} -A riscv -O u-boot -T firmware visionfive2_fw_payload.img

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp u-boot-spl.bin.normal.out $out

    mkdir -p "$out/nix-support"
    echo "file binary-dist u-boot-spl.bin.normal.out" >> "$out/nix-support/hydra-build-products"

    cp visionfive2_fw_payload.img $out
    echo "file binary-dist visionfive2_fw_payload.img" >> "$out/nix-support/hydra-build-products"

    runHook postInstall
  '';
}
