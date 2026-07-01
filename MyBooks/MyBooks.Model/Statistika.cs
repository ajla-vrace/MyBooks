public class StatistikaResponse
{
    public int UkupnoKnjiga { get; set; }

    public double ProsjecnaOcjena { get; set; }

    public List<BrojPoMjesecu> KnjigePoMjesecima { get; set; } = new();

    public List<ZanrStatistika> TopZanrovi { get; set; } = new();
}

public class BrojPoMjesecu
{
    public string Mjesec { get; set; } = "";
    public int Broj { get; set; }
}

public class ZanrStatistika
{
    public string Naziv { get; set; } = "";
    public int Broj { get; set; }
    public double Postotak { get; set; }
}