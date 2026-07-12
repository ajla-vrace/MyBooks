using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model
{
    public class KorisnikZnacka
    {
        public int Id { get; set; }
        public int KorisnikId { get; set; }
        public int ZnackaId { get; set; }
        public DateTime? DatumOtkljucavanja { get; set; }

    }
}
