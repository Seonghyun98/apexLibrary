

//datatype change size, type
public with sharing class DataTypeFunction {

    // String => String (size(len))
    public static String chString(string src, Integer len){
        String strReturn = '';
        if(src != null) {
            src = src.trim();
            if(src.length() >= len){
                strReturn = src.substring(0, len);
            }
            else {
                strReturn = src;
            }
        }
        return strReturn;
    }

    //Decimal => interger (size(len))
    public static Integer decimalChInteger(Decimal dec, Integer len){
        string str = String.valueOf(dec);
        Integer num;
        if(str.length() >= len){
            str = str.substring(0,len);
            num = Integer.valueOf(str);
            return num;
        }
        else {
            num = Integer.valueOf(str);
            return num;
        } 
    }

    
    //string -> delete space -> integer (size(len))
    public static Integer chInteger(string src, Integer len){
        src = src.replace(' ','');
        integer num;
        if(src.length() >= len){
            num = Integer.valueOf(src.substring(0, len));
            return num;
        }
        else {
            num = Integer.valueOf(src);
            return num;
        } 
    }

    //date -> string (YYYYMMDD)
    public static String DateChString(Date d){
        String Month = String.valueof(d.month());
        String Day = String.valueof(d.day());
        if(Month.length()==1){
            Month = '0' + Month;
          }
          if(Day.length()==1){
            Day = '0' + Day;
          }
          String Today = String.valueof(d.year()) + Month + Day;
          return Today;
    }
}
