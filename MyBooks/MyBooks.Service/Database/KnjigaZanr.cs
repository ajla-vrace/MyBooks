using System;
using System.Collections.Generic;

namespace MyBooks.Service.Database
{
    public partial class KnjigaZanr
    {
        public int Id { get; set; }
        public int IdKnjiga { get; set; }
        public int IdZanr { get; set; }

        public virtual Knjiga IdKnjigaNavigation { get; set; } = null!;
        public virtual Zanr IdZanrNavigation { get; set; } = null!;
    }
}
