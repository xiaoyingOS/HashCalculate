# 使用说明
此程序/脚本 复制到某个目录  双击运行即可
计算哈希值追加到*Hash.json和*Hash.txt文件中【多次计算也是追加到*Hash.json文件中】

## HashCalculate.exe使用【windows系统建议用这个 性能好一点】
复制到某个目录  双击运行即可 根据提示选择是否计算子文件夹中的文件
【也可以用cmd 把HashCalculate.exe文件 拖进去回车运行 不用复制到某个目录】

PS: 目前已知问题，多线程计算哈希值，磁盘占用过高，大文件同时计算哈希值很容易到100%
    解决办法可以用其他开源项目计算哈希值 不使用WindowsAPI计算更好。。。

### Script脚本使用
复制到某个目录  双击运行即可
Windows .ps1/cmd: 复制到某个目录  双击00__双击运行我即可.bat文件即可
00_*.sh: 所有平台都可以用，Windows使用需要安装Git。Linux可以直接使用【00_CPU_Xargs_Hash.sh为多线程计算哈希值】
     Android需要安装Termux/MT管理器用终端运行.sh文件【新版MT管理器也运行不了00_CPU_Xargs_Hash.sh文件】

kill_bash目录下的文件，用来停止.sh脚本运行

PS: 目前已知问题，多线程计算哈希值，磁盘占用过高，大文件同时计算哈希值很容易到100%
    .sh有时间再重写，.bat/.ps1文件解决不了 是windows的问题


hash.json
[
    {
        "File": "HashCalculate/.git/HEAD",
        "SizeBytes": 21,
        "MD5": "cf7dd3ce51958c5f13fece957cc417fb",
        "SHA1": "9f1df7eea4156be8a871c292b549b3325e425aa2",
        "SHA256": "28d25bf82af4c0e2b72f50959b2beb859e3e60b9630a5e8c603dad4ddb2b6e80",
        "SHA384": "55b12966f4c89b6e367bd4a38c0c69307d45d45525e592b3b6352cccdfb6eeb97039889306916dea94d286e6c4f8e820",
        "SHA512": "8bc9f17f0628c3ce935ddac3d15cd482a756797f19287a4a5b96e0e3cf37cf90c421949b2e82d65714b274c8b455ac522d88123be83ee2efd85eac5fba94ca80"
    },
    {
        "File": "HashCalculate/.git/description",
        "SizeBytes": 73,
        "MD5": "a0a7c3fff21f2aea3cfa1d0316dd816c",
        "SHA1": "9635f1b7e12c045212819dd934d809ef07efa2f4",
        "SHA256": "85ab6c163d43a17ea9cf7788308bca1466f1b0a8d1cc92e26e9bf63da4062aee",
        "SHA384": "337b8e4b134b6a2f63b596976134bad351ae3e61d57feddaa18d6d662e81c9186d94b51faf49ec17ffb2514daacb7fe5",
        "SHA512": "f7e152f75b124c3e1c5d12f00427729d9eec4e2c1bf70d7606440a6600d003367eb178331e75ab976a61496e79c2c822020849d28ffd170946397b934611b471"
    },
    {
        "File": "HashCalculate/.git/hooks/commit-msg.sample",
        "SizeBytes": 896,
        "MD5": "579a3c1e12a1e74a98169175fb913012",
        "SHA1": "ee1ed5aad98a435f2020b6de35c173b75d9affac",
        "SHA256": "1f74d5e9292979b573ebd59741d46cb93ff391acdd083d340b94370753d92437",
        "SHA384": "2f4187279321ed2edbf578e2dda2e357a61856649974ec96d7e376f2a3e0d7f83ac5472ddc906ca7243d84712d8ee300",
        "SHA512": "d6bb7fa747f4625adf1877f546565cbe812ca7dd4168f7e9068e6732555d8737eba549546cf5946649e3f38de82d173aaf9c160a4c9f9445655258b4c5f955eb"
    },
    {
        "File": "HashCalculate/.git/config",
        "SizeBytes": 365,
        "MD5": "780ca362053c6fce6c449215102b6c8b",
        "SHA1": "4fa14bc22c75f74adaed7565e3d029aea8fe571a",
        "SHA256": "22dfa417d97d67737fed7ac55fad0cb692456a3766511ef23b652065b9c4f1c2",
        "SHA384": "a5c7edf03c243460e18d0c4b9b47d9651b33ab9e04e57d2fbd9e1de448a649ce1df17f5d62eadc07441e392c08f80516",
        "SHA512": "5def80c6e3bf2971567c094b04d5a038d5422c2a1e3b952c476a39cc0922fd8cd2136f89e3b9d2df3e01c30c4380346197a6cf38181443372869eb292479532c"
    },
    {
        "File": "HashCalculate/.git/hooks/applypatch-msg.sample",
        "SizeBytes": 478,
        "MD5": "ce562e08d8098926a3862fc6e7905199",
        "SHA1": "4de88eb95a5e93fd27e78b5fb3b5231a8d8917dd",
        "SHA256": "0223497a0b8b033aa58a3a521b8629869386cf7ab0e2f101963d328aa62193f7",
        "SHA384": "d730eb349d44269b98c8a79439e74685de51b5d68e1d4e499320218c7df4de19b27926c578a0cd331f20e8dd76c1b208",
        "SHA512": "536cce804d84e25813993efdd240537b52d00ce9cdcecf1982f85096d56a521290104c825c00b370b2752201952a9616a3f4e28c5d27a5b4e4842101a2ff9bee"
    },
    {
        "File": "HashCalculate/.git/hooks/fsmonitor-watchman.sample",
        "SizeBytes": 4726,
        "MD5": "a0b2633a2c8e97501610bd3f73da66fc",
        "SHA1": "0ec0ec9ac11111433d17ea79e0ae8cec650dcfa4",
        "SHA256": "e0549964e93897b519bd8e333c037e51fff0f88ba13e086a331592bf801fa1d0",
        "SHA384": "5b6f4b29a3c2b3af592e6f223a7cb19114947da57f646d6557e1e02ee02c504bb10373c81856f9936cddac513384c69e",
        "SHA512": "5168643c1768ec83554a9066754507a781b6d14251a46a469222d462efc6ca87a72c90679154e8a723349c91e7772b32ac9b08dfe313cded0ee0a6f17885079e"
    },
    {
        "File": "HashCalculate/.git/hooks/post-update.sample",
        "SizeBytes": 189,
        "MD5": "2b7ea5cee3c49ff53d41e00785eb974c",
        "SHA1": "b614c2f63da7dca9f1db2e7ade61ef30448fc96c",
        "SHA256": "81765af2daef323061dcbc5e61fc16481cb74b3bac9ad8a174b186523586f6c5",
        "SHA384": "6d09ce0e4018195f798f47dd88874385475af02dbc5493928714659337f735051714edefc5c11c4805d4beb293afadb6",
        "SHA512": "473ad124642571656276bf83b9ff63ab1804d3c23a5bdae52391c6f70a894849ac60c10c9d31deff3938922ce83b68b1e60c11592bbf7ea503f4acd39968cefa"
    },
    {
        "File": "HashCalculate/.git/hooks/pre-applypatch.sample",
        "SizeBytes": 424,
        "MD5": "054f9ffb8bfe04a599751cc757226dda",
        "SHA1": "f208287c1a92525de9f5462e905a9d31de1e2d75",
        "SHA256": "e15c5b469ea3e0a695bea6f2c82bcf8e62821074939ddd85b77e0007ff165475",
        "SHA384": "dfeddbc251f593e088162812d36f162bbcee8745736a32d445e22a3692b321be5a7dee18118fc116e68675f33667fd2e",
        "SHA512": "cb78aa7e9b9c146e5db65d86dd83f04e2b6942a06fab50c704a0fd900683f3b6ad1164e74afe2f267f6da91cdff0b9ab07713e12cefc6f8d741b5df194f4fda6"
    },
    {
        "File": "HashCalculate/.git/hooks/pre-commit.sample",
        "SizeBytes": 1649,
        "MD5": "5029bfab85b1c39281aa9697379ea444",
        "SHA1": "8093d68e142db52dcab2215e770ba0bbe4cfbf24",
        "SHA256": "57185b7b9f05239d7ab52db045f5b89eb31348d7b2177eab214f5eb872e1971b",
        "SHA384": "82e0adfe20bcdfaccf193d54069f740cabfbb2c253a274178bd12e9dfccb7adf92e90521b176048efeecf9abc00a2ac4",
        "SHA512": "4fed684b7e262fc847610ca646074fca45c3c677c40d8fb6c7ae522b9c8a9be7327b41a59b4550ceadd41edf57ec5ed07e575e02dbc6c003951e1822ac3ddd5b"
    },
    {
        "File": "HashCalculate/.git/hooks/pre-merge-commit.sample",
        "SizeBytes": 416,
        "MD5": "39cb268e2a85d436b9eb6f47614c3cbc",
        "SHA1": "04c64e58bc25c149482ed45dbd79e40effb89eb7",
        "SHA256": "d3825a70337940ebbd0a5c072984e13245920cdf8898bd225c8d27a6dfc9cb53",
        "SHA384": "eb57fd9022f85d651cca3c6f928bd0e6dcfcd57e1de8b86bebd8402934998c7bfbad65dde885ec39bbf760ce264b8ba9",
        "SHA512": "e4dc204494f5062efa3032b00c64707a4f38978040482501b3e085f071e3ee5a9737d537e6a52002ceb4ebe2bfe09e555c5d969581e80b3eba2a922015c67960"
    },
    {
        "File": "HashCalculate/.git/hooks/pre-push.sample",
        "SizeBytes": 1374,
        "MD5": "2c642152299a94e05ea26eae11993b13",
        "SHA1": "a599b773b930ca83dbc3a5c7c13059ac4a6eaedc",
        "SHA256": "ecce9c7e04d3f5dd9d8ada81753dd1d549a9634b26770042b58dda00217d086a",
        "SHA384": "7cd09aa4c6c2d32b06998c6aa282dcdfd2287bf0cd99c132c686f65864d0c9455a94774fe897b01e6b5c7adebe2d82d5",
        "SHA512": "cc98bbe0e3865e2023af04416e10689e3aecd3f3928cf90c2acc0d3d7306388886779025c8967c8ea198af1f4fe29d16c65d4e1d546c7a8fa513f5ba7df16850"
    },
    {
        "File": "HashCalculate/.git/hooks/pre-rebase.sample",
        "SizeBytes": 4898,
        "MD5": "56e45f2bcbc8226d2b4200f7c46371bf",
        "SHA1": "288efdc0027db4cfd8b7c47c4aeddba09b6ded12",
        "SHA256": "4febce867790052338076f4e66cc47efb14879d18097d1d61c8261859eaaa7b3",
        "SHA384": "270b69b7adff37f340b4dbbf88db954c8344f5ba13b6a1cf56ec5d2462a0849cda0aa5f8fbe9edcb286bd115f896e7f8",
        "SHA512": "00d21d5d72386c3d9b5a1c36ba85201f730556a8295d4353af54af7892ab81010d42aff209ec1fda61c54e4dda3737cea5fda64f09d40ce5004ae28239565025"
    },
    {
        "File": "HashCalculate/.git/hooks/pre-receive.sample",
        "SizeBytes": 544,
        "MD5": "2ad18ec82c20af7b5926ed9cea6aeedd",
        "SHA1": "705a17d259e7896f0082fe2e9f2c0c3b127be5ac",
        "SHA256": "a4c3d2b9c7bb3fd8d1441c31bd4ee71a595d66b44fcf49ddb310252320169989",
        "SHA384": "dc7de881e10bb029346cef8acab736b1d0e566a9a77b9ffcc155b9bc7b8b8073a8940f0400af5fadc6d474484d03521f",
        "SHA512": "ee08c11fab7e896b2e09c241954ba7640338b12c75cd8040daf053c31b2f22236d7a0deac736f89d305236312fdb4f560a38d4d8debdcc9dcdd23b2d975907d5"
    },
    {
        "File": "HashCalculate/.git/hooks/prepare-commit-msg.sample",
        "SizeBytes": 1492,
        "MD5": "2b5c047bdb474555e1787db32b2d2fc5",
        "SHA1": "2584806ba147152ae005cb675aa4f01d5d068456",
        "SHA256": "e9ddcaa4189fddd25ed97fc8c789eca7b6ca16390b2392ae3276f0c8e1aa4619",
        "SHA384": "018f18174a87a6797833de8cd2459f37b444513fe21958f27ccaf555877721cfb360b077104fd2f555b006ba1635776d",
        "SHA512": "50ec8a0dd98427e80a82a8d8ce44462a845876e1594c9d0e89483ce9a8aaad616edea0e5c45c1bb69d8fe7f520c6f2260d6fa350d77b400899c3ae375e965bfb"
    },
    {
        "File": "HashCalculate/.git/hooks/push-to-checkout.sample",
        "SizeBytes": 2783,
        "MD5": "c7ab00c7784efeadad3ae9b228d4b4db",
        "SHA1": "508240328c8b55f8157c93c43bf5e291e5d2fbcb",
        "SHA256": "a53d0741798b287c6dd7afa64aee473f305e65d3f49463bb9d7408ec3b12bf5f",
        "SHA384": "621403ecad51abcfcc8516f82e7005f9ea096653af6ed2d8be0270b8a80e371392b046e1788664c1ae2e8503ca447a40",
        "SHA512": "586efb6a206f73d8a94561266153a624e2753830bc431a283bed998c46ac00a9df4995ddfd0aa852b1a22b4672c80f2c33cee3fe2e3321e392ff4cef26dbf75e"
    },
    {
        "File": "HashCalculate/.git/hooks/sendemail-validate.sample",
        "SizeBytes": 2308,
        "MD5": "4d67df3a8d5c98cb8565c07e42be0b04",
        "SHA1": "74cf1d5415a5c03c110240f749491297d65c4c98",
        "SHA256": "44ebfc923dc5466bc009602f0ecf067b9c65459abfe8868ddc49b78e6ced7a92",
        "SHA384": "5197e0060098e583c740902ed3510fe4a7bbc90ccbd2d072e28f2981f34653c9ec6ada441c82dbce8f9b7e42feaf5eb7",
        "SHA512": "a19dbbc2ef6c367aadbfb900ae58c377d88ac9b6c0ac6de49c962d44d993418875f64143defda56bae8d0697dcd15be2928d32aa77508d3958769f18a4a53154"
    },
    {
        "File": "HashCalculate/.git/hooks/update.sample",
        "SizeBytes": 3650,
        "MD5": "647ae13c682f7827c22f5fc08a03674e",
        "SHA1": "730e6bd5225478bab6147b7a62a6e2ae21d40507",
        "SHA256": "8d5f2fa83e103cf08b57eaa67521df9194f45cbdbcb37da52ad586097a14d106",
        "SHA384": "6214285b17f26681502fa4c25b6f409c518fb692ca27c1da941c1d6a09c9a5e412e5355131bdbbbe8364eb8222175d31",
        "SHA512": "be3780974589d06eddba6fa0aa15a3e3dfe390e2827a1a6ae5cb83d6ac47e79ef9b1bbb53f067372f8dc70db0350d3770e78537fd3cfe734200ff824eca4cada"
    },
    {
        "File": "HashCalculate/.git/info/exclude",
        "SizeBytes": 240,
        "MD5": "036208b4a1ab4a235d75c181e685e5a3",
        "SHA1": "c879df015d97615050afa7b9641e3352a1e701ac",
        "SHA256": "6671fe83b7a07c8932ee89164d1f2793b2318058eb8b98dc5c06ee0a5a3b0ec1",
        "SHA384": "befecae8042525025063b9763d0ac18b8f5f43402c7bae87f8fbbe4e866acb36543bc292cded1417d20177ce99a6d595",
        "SHA512": "9828c6ecdf91bf117416e17f4ee9caee2e1e37b6fb00b9ff04035ace17a3089b9d0a25c6baa1046c0e1c62d3da88838e8fca74ea82973d6b975905fde58f3072"
    },
    {
        "File": "HashCalculate/HashCalculate.c",
        "SizeBytes": 23269,
        "MD5": "ac139b76e5637860b648ea95f4d5d794",
        "SHA1": "6929c2c6dd31d4950474465a16bad088ac026aa6",
        "SHA256": "1fead348540c925a5898affa0ef1cb575cf81363f20de1e46c6f085385261a61",
        "SHA384": "0d36b26d5cf535307bf15cb442c89158c620fbeaa977fd9f5d56a445ae2c31e5f167b71f64117dab98fffeee9d14fb15",
        "SHA512": "b7d694cdf5985fa9fa1e8406f833f3ed50d380ea90b6ff746f2e4efc5809df596543051adba92afb0b5fe46581bdde0b4a251bddbfed9ed1e82b869c3f264c37"
    },
    {
        "File": "HashCalculate/Script/00_CPU_Xargs_Hash.sh",
        "SizeBytes": 4767,
        "MD5": "4e78bb9efae95aeceff5cf6778083f23",
        "SHA1": "258b020845e7358170452d90ca6c2c9ed20b817f",
        "SHA256": "b81f2ddf70e648dd13e0f632fa32213b026cccede7d26c255e958d807de0dad5",
        "SHA384": "71fb788794aba800a685daeafe0d6b3392d22ef6b02c7917e02877246dfeb4051a87f67499d4c388b6db6278acef2f66",
        "SHA512": "f899f6851f7ad5561ef3d7842563d31f06d4881fcd6ac6ac469647d4d3ea0ed5d7b170db723996b12d081ed545a704d568e32f5093e994670e0d8bd3652b69eb"
    },
    {
        "File": "HashCalculate/Script/00_JSON_Hash.sh",
        "SizeBytes": 3557,
        "MD5": "d1f9298e807e122b0e554e906d13c5b4",
        "SHA1": "22358e8ded13d267fd255670871b470ac43c56a6",
        "SHA256": "e4626d35ae7679bc256fbc57ebd3ad8270258fa4c7f60a6ceb880ac542613233",
        "SHA384": "6612762141c51e9176b5d28e3299aaee7a874f38f8a0981e2143a565d2422a37ac518472da40e24b162c0aa1b5ea3bfd",
        "SHA512": "0e2e069c83b88d1a5fdfce0be577be548d2d1574bb8c334c0cf75038a544dac6bbfed311da89f2f039b310f2cdaa1e74ee017382e1be1e01c6016967b096e9e8"
    },
    {
        "File": "HashCalculate/Script/kill_bash/kill_bash.bat",
        "SizeBytes": 228,
        "MD5": "2c35b0141e0e9696f79566b428099b8a",
        "SHA1": "0bf80fd980206de17009d077c07ad9f8eee83ea5",
        "SHA256": "14662c14f266912519c4c9308f301f275eafbfdce5245a4856849106eae03523",
        "SHA384": "06d939486e8dfe42a62f7ca4955d1094e01b66e5c76cdc36a477123548ae7581e6f14f7b7b3c07646f901516513fe05d",
        "SHA512": "6128f5b38383b388b1f5ec76decb16f8cfde4b309b58637bcc9d34f51f4c74a228ccd3549ff3bac3c16ce0ca6d95bf49f7a1235205c1e658c9192b0c8bbeb411"
    },
    {
        "File": "HashCalculate/Script/kill_bash/kill_bash.sh",
        "SizeBytes": 550,
        "MD5": "57d29faa9d2614bc221c8cc86fe201e2",
        "SHA1": "cb51971a51d766ce05e9058b8e08091d25166e05",
        "SHA256": "62f5c77c706dadf207aa8d331d864103a04853517e2afbbddea526c83bdb58ce",
        "SHA384": "2e16a7bcfeab410e69f86e240dc831b12e7f9b1a2bb8175caf6746e9e89c6566dc8c71b3cf72fadddb945e4392972bf7",
        "SHA512": "5dcd4bde940b3c47b8e5c417138f55bb7f24a0bf866e3fd5624341aca7b3a921e16489c0709cf7b7089cda520be4958ef5c730843e47111b982a088f38d5f0c9"
    },
    {
        "File": "HashCalculate/Script/kill_bash/README.txt",
        "SizeBytes": 257,
        "MD5": "fa614a0190ff01ff40a1f46f4a9e4863",
        "SHA1": "d28ca4828eb151c2a07e4ee571aeb397f2e504d9",
        "SHA256": "9476c5280ba9342087f35a8770d8b58a8dcd0ae8d94fe998be2bdd609d6b4042",
        "SHA384": "1b3551a30c08ac0b9c473201b7054d356de7f74e14a5a5acdf01c3dca1c0b733d4b6e136a4db1df32be0434438b12858",
        "SHA512": "88dffab83513d01ecc18960917f98d72b41097081b05e5e268156a98bfdee3527f1ccec7a7bf7350a3d3213335b38d575a1fa6e09525f8d279a2b60100aa8df7"
    },
    {
        "File": "HashCalculate/Script/Windows/00_Hash.ps1",
        "SizeBytes": 14737,
        "MD5": "57b95c2146691f0e2ff6a1954be48976",
        "SHA1": "cf66cf65094cb4af67978b9071b3c0b085f68b0e",
        "SHA256": "9a18db264fdf306b73647aeaeec258d4be4b075b652512efeeba8fd9447b5dd5",
        "SHA384": "12c3daf62a6fe4d37458e160d4e262f7b4669d22574f3109df83aad7d341088659bc5bc9f4843303f06f136b7040e6d4",
        "SHA512": "f149a3f15a4bdbaa08354020f97ffe1d5efdfcb00a641e579e6cbe87e70d686f9c26744b9aecbd8ff5528af1a8c0e66026dcaa8c354a503fe98e44b9d9cef4cf"
    },
    {
        "File": "HashCalculate/Script/Windows/00__双击运行我即可.bat",
        "SizeBytes": 136,
        "MD5": "99cae041e9f82e391e7a98949a3f1a78",
        "SHA1": "a0d626f9a2e8e8712cf8471a5a121c7c96cbc845",
        "SHA256": "cff51ad4bee4839c279f64350527e0908d7d05847d1fe2d3bd7588b10f0bc24e",
        "SHA384": "285fe66a5120704c9d31b2882c6be3a7935afa314de19cb6d60a8c4f86ffad3275e8f98d55c3cf4b05bdbf2dcd0037cd",
        "SHA512": "ecf5c84b403d1b06a6619e32b9fb13d24e3a59a58f448804d84e1e6d63b208738e7118ef1173863e28e278e83db56468c9f9094fcb243c4a8f850f28052c836b"
    }
]