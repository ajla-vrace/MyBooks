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
    public class KnjigaService : BaseCRUDService<Model.Knjiga, Database.Knjiga, KnjigaSearchObject, KnjigaInsertRequest, KnjigaUpdateRequest>, IKnjigaService
    {
        private readonly IKorisnikZnackaService _korisnikZnackaService;
        public KnjigaService(
     MyBooksContext context,
     IMapper mapper,
     IKorisnikZnackaService korisnikZnackaService)
     : base(context, mapper)
        {
            _korisnikZnackaService = korisnikZnackaService;
        }

        public override IQueryable<Database.Knjiga> AddFilter(IQueryable<Database.Knjiga> query, KnjigaSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Naslov))
            {
                filteredQuery = filteredQuery.Where(x => x.Naslov.Contains(search.Naslov));
            }
            if (!string.IsNullOrWhiteSpace(search?.Autor))
            {
                filteredQuery = filteredQuery.Where(x => x.Autor.Contains(search.Autor));
            }

            if (search?.KorisnikId.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.KorisnikId == search.KorisnikId);
            }

            /* filteredQuery = filteredQuery
    .Include(x => x.KnjigaZanrs)
        .ThenInclude(x => x.IdZanrNavigation);*/

            filteredQuery = filteredQuery
      .Include(x => x.KnjigaZanrs)
          .ThenInclude(x => x.IdZanrNavigation);
     // .Include(x => x.Citats);   // <-- DODANO


            if (search?.ZanrId != null)
            {
                int zanrId = search.ZanrId.Value;

                filteredQuery = filteredQuery.Where(x =>
                    x.KnjigaZanrs.Any(kz => kz.IdZanr == zanrId)
                );
            }
            if (search?.NaDanasnjiDan == true)
            {
                var danas = DateTime.Today;

                filteredQuery = filteredQuery.Where(x =>
                    x.DatumKreiranja.HasValue &&
                    x.DatumKreiranja.Value.Month == danas.Month &&
                    x.DatumKreiranja.Value.Day == danas.Day
                );
            }


            // SORTIRANJE

            if (search?.Sort == "najnovije")
            {
                filteredQuery =
                    filteredQuery
                    .OrderByDescending(x => x.DatumKreiranja);
            }


            if (search?.Sort == "ocjena")
            {
                filteredQuery =
                    filteredQuery
                    .OrderByDescending(x => x.Ocjena);
            }


            if (search?.Sort == "az")
            {
                filteredQuery =
                    filteredQuery
                    .OrderBy(x => x.Naslov);
            }


            if (search?.Sort == "za")
            {
                filteredQuery =
                    filteredQuery
                    .OrderByDescending(x => x.Naslov);
            }

            // Ako je korisničko ime i naziv usluge uneseno


            return filteredQuery;
        }


        

        public override async Task<Model.Knjiga> Insert(KnjigaInsertRequest insert)
        {
            var entity = _mapper.Map<Database.Knjiga>(insert);

            if (!string.IsNullOrEmpty(insert.SlikaBase64))
            {
                entity.Slika = Convert.FromBase64String(insert.SlikaBase64);
            }

            entity.DatumKreiranja = DateTime.Now;
            entity.DatumPocetka = DateTime.Now;
            entity.DatumZavrsetka = DateTime.Now;

            _context.Knjigas.Add(entity);

            await _context.SaveChangesAsync();


            if (insert.ZanroviIds != null && insert.ZanroviIds.Count > 0)
            {
                foreach (var zanrId in insert.ZanroviIds)
                {
                    _context.KnjigaZanrs.Add(new Database.KnjigaZanr
                    {
                        IdKnjiga = entity.Id,
                        IdZanr = zanrId
                    });
                }

                await _context.SaveChangesAsync();
            }


            // PROVJERA ZNAČKI IDE OVAKO
            await _korisnikZnackaService
                .ProvjeriZnacke(entity.KorisnikId);



            var knjiga = await _context.Knjigas
                .Include(k => k.KnjigaZanrs)
                .ThenInclude(kz => kz.IdZanrNavigation)
                .FirstAsync(k => k.Id == entity.Id);


            return _mapper.Map<Model.Knjiga>(knjiga);
        }


        /* public override async Task<Model.Knjiga> Update(int id, KnjigaUpdateRequest update)
         {
             var entity = await _context.Knjigas.FindAsync(id);
             if (entity == null)
             {
                 throw new KeyNotFoundException("Knjiga nije pronađen.");
             }

             _mapper.Map(update, entity);


             _context.Knjigas.Update(entity);
             await _context.SaveChangesAsync();

             return _mapper.Map<Model.Knjiga>(entity);
         }*/


        public override async Task<Model.Knjiga> Update(
    int id,
    KnjigaUpdateRequest update)
        {

            var entity = await _context.Knjigas.FindAsync(id);


            if (entity == null)
            {
                throw new KeyNotFoundException(
                    "Knjiga nije pronađen."
                );
            }



            _mapper.Map(update, entity);



            _context.Knjigas.Update(entity);


            await _context.SaveChangesAsync();



            // ==========================
            // PROVJERA ZNAČKI
            // nakon update-a
            // ==========================

            await _korisnikZnackaService
                .ProvjeriZnacke(entity.KorisnikId);



            return _mapper.Map<Model.Knjiga>(entity);
        }
        public async Task<StatistikaResponse> GetStatistika(int korisnikId)
        {
            /*var knjige = await _context.Knjigas
                .Include(x => x.KnjigaZanrs)
                .ThenInclude(x => x.IdZanrNavigation)
                .ToListAsync();*/
            var knjige = await _context.Knjigas
    .Where(x => x.KorisnikId == korisnikId)
    .Include(x => x.KnjigaZanrs)
    .ThenInclude(x => x.IdZanrNavigation)
    .ToListAsync();

            var result = new StatistikaResponse();

            result.UkupnoKnjiga = knjige.Count;

            result.ProsjecnaOcjena = knjige.Any()
                ? knjige.Average(x => x.Ocjena ?? 0)
                : 0;
            result.HistogramOcjena = Enumerable.Range(1, 5)
      .Select(o => new OcjenaStatistika
      {
          Ocjena = o,
          Broj = knjige.Count(x => x.Ocjena == o)
      })
      .OrderByDescending(x => x.Ocjena)
      .ToList();

            result.KnjigePoMjesecima = knjige
                .GroupBy(x => x.DatumKreiranja!.Value.Month)
                .Select(x => new BrojPoMjesecu
                {
                    Mjesec = x.Key.ToString(),
                    Broj = x.Count()
                })
                .OrderBy(x => int.Parse(x.Mjesec))
                .ToList();

            var sviZanrovi = knjige
                .SelectMany(x => x.KnjigaZanrs)
                .GroupBy(x => x.IdZanrNavigation.Naziv)
                .Select(x => new ZanrStatistika
                {
                    Naziv = x.Key,
                    Broj = x.Count(),
                    Postotak = 0
                })
                .OrderByDescending(x => x.Broj)
                .Take(3)
                .ToList();

            int ukupnoZanrova = sviZanrovi.Sum(x => x.Broj);

            foreach (var z in sviZanrovi)
            {
                z.Postotak = ukupnoZanrova == 0
                    ? 0
                    : Math.Round((double)z.Broj / ukupnoZanrova * 100, 1);
            }

            result.TopZanrovi = sviZanrovi;
            /* var topAutori = _context.Knjigas
      .Where(k => !string.IsNullOrEmpty(k.Autor))
      .GroupBy(k => k.Autor)
      .Select(g => new AutorStatistika
      {
          ImeAutora = g.Key,
          BrojKnjiga = g.Count()
      })
      .OrderByDescending(x => x.BrojKnjiga)
      .Take(5)
      .ToList();*/
            var topAutori = _context.Knjigas
     .Where(k => k.KorisnikId == korisnikId)
     .Where(k => !string.IsNullOrEmpty(k.Autor))
     .GroupBy(k => k.Autor)
     .Select(g => new AutorStatistika
     {
         ImeAutora = g.Key,
         BrojKnjiga = g.Count()
     })
     .OrderByDescending(x => x.BrojKnjiga)
     .Take(5)
     .ToList();


            result.TopAutori = topAutori;

            /*
                        var moodStatistika = await _context.Knjigas
                .Where(x => x.Mood != null)
                .GroupBy(x => x.Mood)
                .Select(g => new MoodStatistika
                {
                    Mood = g.Key,
                    Broj = g.Count()
                })
                .OrderByDescending(x => x.Broj)
                .ToListAsync();*/

            var moodStatistika = await _context.Knjigas
    .Where(x => x.KorisnikId == korisnikId)
    .Where(x => x.Mood != null)
    .GroupBy(x => x.Mood)
    .Select(g => new MoodStatistika
    {
        Mood = g.Key,
        Broj = g.Count()
    })
    .OrderByDescending(x => x.Broj)
    .ToListAsync();

            result.MoodStatistika = moodStatistika;


            // =======================
            // ŽANROVSKI DNK
            // =======================

            var sviTagovi = knjige
                .SelectMany(k => k.KnjigaZanrs)
                .ToList();

            int ukupnoTagova = sviTagovi.Count;

            result.ZanrovskiDNK = sviTagovi
                .GroupBy(x => x.IdZanrNavigation.Naziv)
                .Select(g => new ZanrStatistika
                {
                    Naziv = g.Key,
                    Broj = g.Count(),
                    Postotak = ukupnoTagova == 0
                        ? 0
                        : Math.Round((double)g.Count() * 100 / ukupnoTagova, 1)
                })
                .OrderByDescending(x => x.Broj)
                .ToList();



            return result;
        }
        public override async Task<bool> Delete(int id)
        {
            var entity = await _context.Knjigas
                .Include(x => x.KnjigaZanrs)
                .FirstOrDefaultAsync(x => x.Id == id);

            if (entity == null)
                return false;

            _context.KnjigaZanrs.RemoveRange(entity.KnjigaZanrs);
            _context.Knjigas.Remove(entity);

            await _context.SaveChangesAsync();

            return true;
        }
    }
}
