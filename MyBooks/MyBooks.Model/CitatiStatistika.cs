public class CitatiStatistika
{
    public bool DodanoDanas { get; set; }

    public int TrenutniNiz { get; set; }

    public int NajduziNiz { get; set; }

    public string? TekstCitata { get; set; }

    public string? NazivKnjige { get; set; }

    public int? BrojStranice { get; set; }
    public List<CitatPoDanu> CitatiPoDanima { get; set; } = new();
}
public class CitatPoDanu
{
    public DateTime Datum { get; set; }
    public int Broj { get; set; }
}