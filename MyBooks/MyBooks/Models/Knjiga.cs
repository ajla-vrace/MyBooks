using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyBooks.Models
{
    [Table("Knjiga")]
    public partial class Knjiga
    {
        public Knjiga()
        {
            Citats = new HashSet<Citat>();
            KnjigaZanrs = new HashSet<KnjigaZanr>();
        }

        [Key]
        public int Id { get; set; }
        [StringLength(255)]
        public string Naslov { get; set; } = null!;
        [StringLength(255)]
        public string Autor { get; set; } = null!;
        public string? Opis { get; set; }
        public int? Ocjena { get; set; }
        [StringLength(50)]
        public string? Status { get; set; }
        public string? Recenzija { get; set; }
        [Column(TypeName = "date")]
        public DateTime? DatumPocetka { get; set; }
        [Column(TypeName = "date")]
        public DateTime? DatumZavrsetka { get; set; }
        [Column(TypeName = "datetime")]
        public DateTime? DatumKreiranja { get; set; }

        [InverseProperty(nameof(Citat.IdKnjigaNavigation))]
        public virtual ICollection<Citat> Citats { get; set; }
        [InverseProperty(nameof(KnjigaZanr.IdKnjigaNavigation))]
        public virtual ICollection<KnjigaZanr> KnjigaZanrs { get; set; }
    }
}
