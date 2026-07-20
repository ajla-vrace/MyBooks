using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model
{
    public class Znacka
    {
        public int Id { get; set; }
        public string Naziv { get; set; } = null!;
        public string? Opis { get; set; }
        public string? Ikonica { get; set; }
        public string Tip { get; set; } = null!;
        public int Prag { get; set; }
        public int? Nivo { get; set; }
        public int TrenutniNapredak { get; set; }   // novo

        // NOVO
        public int Preostalo => Math.Max(0, Prag - TrenutniNapredak);

        public double Procenat =>
            Prag == 0
                ? 0
                : Math.Min(1.0, (double)TrenutniNapredak / Prag);
    }
}
