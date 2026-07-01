using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace MyBooks.Models
{
    [Table("Citat")]
    public partial class Citat
    {
        [Key]
        public int Id { get; set; }
        public int IdKnjiga { get; set; }
        public string? TekstCitata { get; set; }
        public int? BrojStranice { get; set; }
        public bool? JeOmiljeni { get; set; }
        [Column(TypeName = "datetime")]
        public DateTime? DatumKreiranja { get; set; }

        [ForeignKey(nameof(IdKnjiga))]
        [InverseProperty(nameof(Knjiga.Citats))]
        public virtual Knjiga IdKnjigaNavigation { get; set; } = null!;
    }
}
