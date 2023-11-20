{ lib, beamPackages, overrides ? (x: y: {}) }:

let
  buildRebar3 = lib.makeOverridable beamPackages.buildRebar3;
  buildMix = lib.makeOverridable beamPackages.buildMix;
  buildErlangMk = lib.makeOverridable beamPackages.buildErlangMk;

  self = packages // (overrides self packages);

  packages = with beamPackages; with self; {
    bunt = buildMix rec {
      name = "bunt";
      version = "0.2.1";

      src = fetchHex {
        pkg = "bunt";
        version = "${version}";
        sha256 = "a330bfb4245239787b15005e66ae6845c9cd524a288f0d141c148b02603777a5";
      };

      beamDeps = [];
    };

    castore = buildMix rec {
      name = "castore";
      version = "1.0.4";

      src = fetchHex {
        pkg = "castore";
        version = "${version}";
        sha256 = "9418c1b8144e11656f0be99943db4caf04612e3eaecefb5dae9a2a87565584f8";
      };

      beamDeps = [];
    };

    credo = buildMix rec {
      name = "credo";
      version = "1.7.0";

      src = fetchHex {
        pkg = "credo";
        version = "${version}";
        sha256 = "6839fcf63d1f0d1c0f450abc8564a57c43d644077ab96f2934563e68b8a769d7";
      };

      beamDeps = [ bunt file_system jason ];
    };

    db_connection = buildMix rec {
      name = "db_connection";
      version = "2.5.0";

      src = fetchHex {
        pkg = "db_connection";
        version = "${version}";
        sha256 = "c92d5ba26cd69ead1ff7582dbb860adeedfff39774105a4f1c92cbb654b55aa2";
      };

      beamDeps = [ telemetry ];
    };

    decimal = buildMix rec {
      name = "decimal";
      version = "2.1.1";

      src = fetchHex {
        pkg = "decimal";
        version = "${version}";
        sha256 = "53cfe5f497ed0e7771ae1a475575603d77425099ba5faef9394932b35020ffcc";
      };

      beamDeps = [];
    };

    dialyxir = buildMix rec {
      name = "dialyxir";
      version = "1.4.1";

      src = fetchHex {
        pkg = "dialyxir";
        version = "${version}";
        sha256 = "84b795d6d7796297cca5a3118444b80c7d94f7ce247d49886e7c291e1ae49801";
      };

      beamDeps = [ erlex ];
    };

    earmark_parser = buildMix rec {
      name = "earmark_parser";
      version = "1.4.35";

      src = fetchHex {
        pkg = "earmark_parser";
        version = "${version}";
        sha256 = "8652ba3cb85608d0d7aa2d21b45c6fad4ddc9a1f9a1f1b30ca3a246f0acc33f6";
      };

      beamDeps = [];
    };

    ecto = buildMix rec {
      name = "ecto";
      version = "3.11.0";

      src = fetchHex {
        pkg = "ecto";
        version = "${version}";
        sha256 = "7769dad267ef967310d6e988e92d772659b11b09a0c015f101ce0fff81ce1f81";
      };

      beamDeps = [ decimal jason telemetry ];
    };

    ecto_sql = buildMix rec {
      name = "ecto_sql";
      version = "3.10.2";

      src = fetchHex {
        pkg = "ecto_sql";
        version = "${version}";
        sha256 = "68c018debca57cb9235e3889affdaec7a10616a4e3a80c99fa1d01fdafaa9007";
      };

      beamDeps = [ db_connection ecto postgrex telemetry ];
    };

    erlex = buildMix rec {
      name = "erlex";
      version = "0.2.6";

      src = fetchHex {
        pkg = "erlex";
        version = "${version}";
        sha256 = "2ed2e25711feb44d52b17d2780eabf998452f6efda104877a3881c2f8c0c0c75";
      };

      beamDeps = [];
    };

    ex_doc = buildMix rec {
      name = "ex_doc";
      version = "0.30.6";

      src = fetchHex {
        pkg = "ex_doc";
        version = "${version}";
        sha256 = "bd48f2ddacf4e482c727f9293d9498e0881597eae6ddc3d9562bd7923375109f";
      };

      beamDeps = [ earmark_parser makeup_elixir makeup_erlang ];
    };

    file_system = buildMix rec {
      name = "file_system";
      version = "0.2.10";

      src = fetchHex {
        pkg = "file_system";
        version = "${version}";
        sha256 = "41195edbfb562a593726eda3b3e8b103a309b733ad25f3d642ba49696bf715dc";
      };

      beamDeps = [];
    };

    finch = buildMix rec {
      name = "finch";
      version = "0.16.0";

      src = fetchHex {
        pkg = "finch";
        version = "${version}";
        sha256 = "f660174c4d519e5fec629016054d60edd822cdfe2b7270836739ac2f97735ec5";
      };

      beamDeps = [ castore mime mint nimble_options nimble_pool telemetry ];
    };

    hpax = buildMix rec {
      name = "hpax";
      version = "0.1.2";

      src = fetchHex {
        pkg = "hpax";
        version = "${version}";
        sha256 = "2c87843d5a23f5f16748ebe77969880e29809580efdaccd615cd3bed628a8c13";
      };

      beamDeps = [];
    };

    jason = buildMix rec {
      name = "jason";
      version = "1.4.1";

      src = fetchHex {
        pkg = "jason";
        version = "${version}";
        sha256 = "fbb01ecdfd565b56261302f7e1fcc27c4fb8f32d56eab74db621fc154604a7a1";
      };

      beamDeps = [ decimal ];
    };

    makeup = buildMix rec {
      name = "makeup";
      version = "1.1.0";

      src = fetchHex {
        pkg = "makeup";
        version = "${version}";
        sha256 = "0a45ed501f4a8897f580eabf99a2e5234ea3e75a4373c8a52824f6e873be57a6";
      };

      beamDeps = [ nimble_parsec ];
    };

    makeup_elixir = buildMix rec {
      name = "makeup_elixir";
      version = "0.16.1";

      src = fetchHex {
        pkg = "makeup_elixir";
        version = "${version}";
        sha256 = "e127a341ad1b209bd80f7bd1620a15693a9908ed780c3b763bccf7d200c767c6";
      };

      beamDeps = [ makeup nimble_parsec ];
    };

    makeup_erlang = buildMix rec {
      name = "makeup_erlang";
      version = "0.1.2";

      src = fetchHex {
        pkg = "makeup_erlang";
        version = "${version}";
        sha256 = "f3f5a1ca93ce6e092d92b6d9c049bcda58a3b617a8d888f8e7231c85630e8108";
      };

      beamDeps = [ makeup ];
    };

    mime = buildMix rec {
      name = "mime";
      version = "2.0.5";

      src = fetchHex {
        pkg = "mime";
        version = "${version}";
        sha256 = "da0d64a365c45bc9935cc5c8a7fc5e49a0e0f9932a761c55d6c52b142780a05c";
      };

      beamDeps = [];
    };

    mint = buildMix rec {
      name = "mint";
      version = "1.5.1";

      src = fetchHex {
        pkg = "mint";
        version = "${version}";
        sha256 = "4a63e1e76a7c3956abd2c72f370a0d0aecddc3976dea5c27eccbecfa5e7d5b1e";
      };

      beamDeps = [ castore hpax ];
    };

    multipart = buildMix rec {
      name = "multipart";
      version = "0.1.1";

      src = fetchHex {
        pkg = "multipart";
        version = "${version}";
        sha256 = "bc349da107810c220ef0366724e445a1a2a39e6be3a361c6a141e0d507eee157";
      };

      beamDeps = [ mime ];
    };

    nimble_options = buildMix rec {
      name = "nimble_options";
      version = "1.0.2";

      src = fetchHex {
        pkg = "nimble_options";
        version = "${version}";
        sha256 = "fd12a8db2021036ce12a309f26f564ec367373265b53e25403f0ee697380f1b8";
      };

      beamDeps = [];
    };

    nimble_parsec = buildMix rec {
      name = "nimble_parsec";
      version = "1.3.1";

      src = fetchHex {
        pkg = "nimble_parsec";
        version = "${version}";
        sha256 = "2682e3c0b2eb58d90c6375fc0cc30bc7be06f365bf72608804fb9cffa5e1b167";
      };

      beamDeps = [];
    };

    nimble_pool = buildMix rec {
      name = "nimble_pool";
      version = "1.0.0";

      src = fetchHex {
        pkg = "nimble_pool";
        version = "${version}";
        sha256 = "80be3b882d2d351882256087078e1b1952a28bf98d0a287be87e4a24a710b67a";
      };

      beamDeps = [];
    };

    plug = buildMix rec {
      name = "plug";
      version = "1.15.2";

      src = fetchHex {
        pkg = "plug";
        version = "${version}";
        sha256 = "02731fa0c2dcb03d8d21a1d941bdbbe99c2946c0db098eee31008e04c6283615";
      };

      beamDeps = [ mime plug_crypto telemetry ];
    };

    plug_crypto = buildMix rec {
      name = "plug_crypto";
      version = "2.0.0";

      src = fetchHex {
        pkg = "plug_crypto";
        version = "${version}";
        sha256 = "53695bae57cc4e54566d993eb01074e4d894b65a3766f1c43e2c61a1b0f45ea9";
      };

      beamDeps = [];
    };

    postgrex = buildMix rec {
      name = "postgrex";
      version = "0.17.3";

      src = fetchHex {
        pkg = "postgrex";
        version = "${version}";
        sha256 = "946cf46935a4fdca7a81448be76ba3503cff082df42c6ec1ff16a4bdfbfb098d";
      };

      beamDeps = [ db_connection decimal jason ];
    };

    supabase_connection = buildMix rec {
      name = "supabase_connection";
      version = "0.1.0";

      src = fetchHex {
        pkg = "supabase_connection";
        version = "${version}";
        sha256 = "5435f2892d13c5f00d26b4a61b3fc823683fc6699936d9b7c201ebf73c33e226";
      };

      beamDeps = [ ecto supabase_types ];
    };

    supabase_fetcher = buildMix rec {
      name = "supabase_fetcher";
      version = "0.1.0";

      src = fetchHex {
        pkg = "supabase_fetcher";
        version = "${version}";
        sha256 = "33725892d1fb51c4d6aca49a6142fa0ef433fd5f20a17113c469f80e090d5c5f";
      };

      beamDeps = [ finch jason ];
    };

    supabase_storage = buildMix rec {
      name = "supabase_storage";
      version = "0.1.0";

      src = fetchHex {
        pkg = "supabase_storage";
        version = "${version}";
        sha256 = "4b8343f8b0c39633bcf8ae7a82b4c92ab22cac66f67bf7bbb2cb948072c192e9";
      };

      beamDeps = [ ecto supabase_connection supabase_fetcher ];
    };

    supabase_types = buildMix rec {
      name = "supabase_types";
      version = "0.1.1";

      src = fetchHex {
        pkg = "supabase_types";
        version = "${version}";
        sha256 = "a8cc84753fdd160f4db4ea31a3c92b60c5efea2d6153a11da19e02943433e42f";
      };

      beamDeps = [ ecto ];
    };

    telemetry = buildRebar3 rec {
      name = "telemetry";
      version = "1.2.1";

      src = fetchHex {
        pkg = "telemetry";
        version = "${version}";
        sha256 = "dad9ce9d8effc621708f99eac538ef1cbe05d6a874dd741de2e689c47feafed5";
      };

      beamDeps = [];
    };
  };
in self

