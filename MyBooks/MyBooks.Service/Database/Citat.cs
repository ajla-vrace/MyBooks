using System;
using System.Collections.Generic;

namespace MyBooks.Service.Database
{
    public partial class Citat
    {
        public int Id { get; set; }
        public int IdKnjiga { get; set; }
        public string? TekstCitata { get; set; }
        public int? BrojStranice { get; set; }
        public bool? JeOmiljeni { get; set; }
        public DateTime? DatumKreiranja { get; set; }

        public virtual Knjiga IdKnjigaNavigation { get; set; } = null!;
    }
}
