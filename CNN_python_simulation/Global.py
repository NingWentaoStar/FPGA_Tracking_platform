


Version=21
tupe_BIT9_1=(8,7)
tuple_BIT18=(17,17)
tuple_BIT18_1=(17,16)
tuple_BIT18_2=(17,15)
tuple_BIT18_3=(17,14)
tuple_BIT18_4=(17,13)
tupe_BIT18_5=(17,12)

name_2_DATA_bitsNum_POS_point={
    "base_net.0.0":
        {
            "input":tupe_BIT9_1,
            "filters":tuple_BIT18_1
        },
    "base_net.0.1":
        {
            "input":tupe_BIT9_1,
            "equivalent_weight": tuple_BIT18_1,#INTEGER位数： 1
            "equivalent_bias": tuple_BIT18#INTEGER位数： 0
        },


    "base_net.1.0":
        {
            "input":tupe_BIT18_5,
            "filters":tuple_BIT18_2
        },
    "base_net.1.1":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_4,#INTEGER位数：4
            "equivalent_bias": tuple_BIT18#INTEGER位数： 0
        },
    "base_net.1.3":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18_1
        },
    "base_net.1.4":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_1,#INTEGER位数： 1
            "equivalent_bias": tuple_BIT18_1#INTEGER位数： 1
        },


    "base_net.2.0":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.2.1":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_3,#INTEGER位数： 3
            "equivalent_bias": tuple_BIT18_1#INTEGER位数： -3为2，-5里为1
        },
    "base_net.2.3":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.2.4":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_1,#INTEGER位数： 1
            "equivalent_bias": tuple_BIT18#INTEGER位数： 0
        },

    "base_net.3.0":
        {
            "input":tupe_BIT18_5,
            "filters":tuple_BIT18
        },
    "base_net.3.1":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_3,#INTEGER位数： 3
            "equivalent_bias": tuple_BIT18_1#INTEGER位数：1
        },
    "base_net.3.3":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.3.4":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight":tuple_BIT18_3,#INTEGER位数： 3
            "equivalent_bias": tuple_BIT18#INTEGER位数： 0
        },

    "base_net.4.0":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.4.1":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight":tuple_BIT18_3,#INTEGER位数：3
            "equivalent_bias": tuple_BIT18_1#INTEGER位数：1
        },
    "base_net.4.3":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.4.4":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_1,#INTEGER位数：1
            "equivalent_bias": tuple_BIT18_1#INTEGER位数：1
        },

    "base_net.5.0":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.5.1":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_4,#INTEGER位数：4
            "equivalent_bias": tuple_BIT18_1#INTEGER位数： -3为2，-5里为1
        },
    "base_net.5.3":
        {
            "input":tupe_BIT18_5,
            "filters":tuple_BIT18
        },
    "base_net.5.4":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight":tuple_BIT18_1,#INTEGER位数：1
            "equivalent_bias": tuple_BIT18#INTEGER位数：0
        },

    "base_net.6.0":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.6.1":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_4,#INTEGER位数：4
            "equivalent_bias": tuple_BIT18_2#INTEGER位数：2
        },
    "base_net.6.3":
        {
            "input":tupe_BIT18_5,
            "filters":tuple_BIT18
        },
    "base_net.6.4":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_1,#INTEGER位数： -3为2，-5里为1
            "equivalent_bias": tuple_BIT18#INTEGER位数： 0
        },

    "base_net.7.0":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.7.1":
        {
            "input":tupe_BIT18_5,
            "equivalent_weight": tuple_BIT18_4,#INTEGER位数：4
            "equivalent_bias":tuple_BIT18_2#INTEGER位数：2
        },
    "base_net.7.3":
        {
            "input":tupe_BIT18_5,
            "filters": tuple_BIT18
        },
    "base_net.7.4":
        {
            "input":tupe_BIT18_5,
                "equivalent_weight": tuple_BIT18_3,#INTEGER位数：3
            "equivalent_bias": tuple_BIT18_1#INTEGER位数：1
        },
    "classification_headers.0.0":
        {
            "input": (17, 13),
            "weight": (17, 13),
            "bias": (17, 13)
        },
    "classification_headers.0.2":
        {
            "input": (17, 13),
            "weight": (17, 13),
            "bias": (17, 13)
        },
    "regression_headers.0.0":
        {
            "input": (17, 13),
            "weight": (17, 13),
            "bias": (17, 13)
        },
    "regression_headers.0.2":
        {
            "input": (17, 13),
            "weight": (17, 13),
            "bias": (17, 13)
        }
}
