using AutoMapper;
using MyBooks.Model.Requests;
using MyBooks.Model.SearchObject;
using MyBooks.Service.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyBooks.Model;
using MyBooks.Service;

namespace MyBooks.Service
{
    public class CitatService : BaseCRUDService<Model.Citat, Database.Citat, CitatSearchObject, CitatInsertRequest, CitatUpdateRequest>, ICitatService
    {
        private readonly IKorisnikZnackaService _korisnikZnackaService;

        public CitatService(
            MyBooksContext context,
            IMapper mapper,
            IKorisnikZnackaService korisnikZnackaService)
            : base(context, mapper)
        {
            _korisnikZnackaService = korisnikZnackaService;
        }

        public override IQueryable<Database.Citat> AddFilter(IQueryable<Database.Citat> query, CitatSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);


            // Ako je korisničko ime i naziv usluge uneseno
            filteredQuery = filteredQuery.Include(x => x.IdKnjigaNavigation);

            if (search?.IdKnjiga > 0)
            {
                filteredQuery = filteredQuery.Where(x => x.IdKnjiga == search.IdKnjiga);
            }
            if (search?.KorisnikId.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.IdKnjigaNavigation.KorisnikId == search.KorisnikId);
            }

            return filteredQuery;
        }


        public override async Task<Model.Citat> Insert(CitatInsertRequest insert)
        {
            // Kreiraj novi entitet
            var entity = _mapper.Map<Database.Citat>(insert);


            // Dodaj citat
            _context.Citats.Add(entity);

            await _context.SaveChangesAsync();



            // Dohvati korisnika preko knjige kojoj pripada citat
            var korisnikId = await _context.Knjigas
                .Where(x => x.Id == entity.IdKnjiga)
                .Select(x => x.KorisnikId)
                .FirstAsync();



            // Provjeri značke nakon dodavanja citata
            await _korisnikZnackaService
                .ProvjeriZnacke(korisnikId);



            return _mapper.Map<Model.Citat>(entity);
        }


        public override async Task<Model.Citat> Update(int id, CitatUpdateRequest update)
        {
            var entity = await _context.Citats.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("Citat nije pronađen.");
            }

            _mapper.Map(update, entity);


            _context.Citats.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Citat>(entity);
        }
        public CitatiStatistika GetStatistika(int korisnikId)
        {
            var danas = DateTime.Today;

            // Samo citati prijavljenog korisnika
            var userCitati = _context.Citats
                .Include(c => c.IdKnjigaNavigation)
                .Where(c => c.IdKnjigaNavigation.KorisnikId == korisnikId);

            // DISTINCT DANI
            var citati = userCitati
                .Where(c => c.DatumKreiranja.HasValue)
                .Select(c => c.DatumKreiranja.Value.Date)
                .Distinct()
                .OrderByDescending(d => d)
                .ToList();

            bool dodanoDanas = citati.Contains(danas);

            var danasnjiCitat = userCitati
                .Where(c => c.DatumKreiranja.HasValue &&
                            c.DatumKreiranja.Value.Date == danas)
                .OrderByDescending(c => c.DatumKreiranja)
                .FirstOrDefault();

            // CURRENT STREAK
            int trenutniNiz = 0;
            var checkDate = danas;

            foreach (var d in citati)
            {
                if (d == checkDate)
                {
                    trenutniNiz++;
                    checkDate = checkDate.AddDays(-1);
                }
                else if (d < checkDate)
                {
                    break;
                }
            }

            // NAJDUŽI STREAK
            int maxStreak = 0;
            int temp = 0;
            DateTime? prev = null;

            foreach (var d in citati.OrderBy(d => d))
            {
                if (prev == null || d == prev.Value.AddDays(1))
                {
                    temp++;
                    maxStreak = Math.Max(maxStreak, temp);
                }
                else
                {
                    temp = 1;
                }

                prev = d;
            }

            // Heatmap
            var citatiPoDanima = userCitati
                .Where(c => c.DatumKreiranja.HasValue)
                .GroupBy(c => c.DatumKreiranja.Value.Date)
                .Select(g => new CitatPoDanu
                {
                    Datum = g.Key,
                    Broj = g.Count()
                })
                .OrderBy(x => x.Datum)
                .ToList();

            return new CitatiStatistika
            {
                DodanoDanas = dodanoDanas,
                TrenutniNiz = trenutniNiz,
                NajduziNiz = maxStreak,
                TekstCitata = danasnjiCitat?.TekstCitata,
                NazivKnjige = danasnjiCitat?.IdKnjigaNavigation?.Naslov,
                BrojStranice = danasnjiCitat?.BrojStranice,
                CitatiPoDanima = citatiPoDanima
            };
        }
    }
}
