using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyBooks.Model
{
    public class Citat
    {
        public int Id { get; set; }
        public int IdKnjiga { get; set; }
        public string? TekstCitata { get; set; }
        public int? BrojStranice { get; set; }
        public bool? JeOmiljeni { get; set; }
        public Knjiga IdKnjigaNavigation { get; set; }

        //public DateTime? DatumKreiranja { get; set; }
    }
}
