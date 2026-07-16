public class StatistikaResponse
{
    public int UkupnoKnjiga { get; set; }

    public double ProsjecnaOcjena { get; set; }

    public List<BrojPoMjesecu> KnjigePoMjesecima { get; set; } = new();

    public List<ZanrStatistika> TopZanrovi { get; set; } = new();
    public List<AutorStatistika> TopAutori { get; set; } = new();
    public List<MoodStatistika> MoodStatistika { get; set; }
    public List<ZanrStatistika> ZanrovskiDNK { get; set; } = new();
}

public class BrojPoMjesecu
{
    public string Mjesec { get; set; } = "";
    public int Broj { get; set; }
}
public class MoodStatistika
{
    public string Mood { get; set; }
    public int Broj { get; set; }
}
public class ZanrStatistika
{
    public string Naziv { get; set; } = "";
    public int Broj { get; set; }
    public double Postotak { get; set; }
}
public class AutorStatistika
{
    public string ImeAutora { get; set; } = "";
    public int BrojKnjiga { get; set; }
}
