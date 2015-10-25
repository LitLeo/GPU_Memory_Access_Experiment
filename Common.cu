#include "Common.h"

string EnumToString(enum data_form df)
{
    switch (df)
    {
    case df_1D:
        return "df_1D";
    case df_2D:
        return "df_2D";
    case df_tree:
        return "df_tree";
    }
    return "";
}
string EnumToString(enum access_mode am)
{
    switch (am)
    {
    case am_sequential:
        return "am_sequential";
    case am_step:
        return "am_step";
    case am_random:
        return "am_random";
    case am_standard_normal:
        return "am_standard_normal";
    case am_poisson:
        return "am_poisson";
    case am_geometric:
        return "am_geometric";
    case am_exponential:
        return "am_exponential";
    }
    return "";
}
string EnumToString(enum data_content dc)
{
    switch (dc)
    {
    case dc_random:
        return "dc_random";
    case dc_standard_normal:
        return "dc_standard_normal";
    case dc_poisson:
        return "dc_poisson";
    case dc_uniform:
        return "dc_uniform";
    case dc_geometric:
        return "dc_geometric";
    case dc_exponential:
        return "dc_exponential";
    }
    return "";
}

void print(DATA_TYPE* data_1D, int size)
{
    for (int i = 0; i < size; i++)
    {
        cout << (float)data_1D[i] << " ";
    }
    cout << endl;
}
