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
    public class ZnackaService : BaseCRUDService<Model.Znacka, Database.Znacka, ZnackaSearchObject, ZnackaInsertRequest, ZnackaUpdateRequest>, IZnackaService
    {
        public ZnackaService(MyBooksContext context, IMapper mapper) : base(context, mapper)
        {

        }

        public override IQueryable<Database.Znacka> AddFilter(IQueryable<Database.Znacka> query, ZnackaSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            // Ako je korisničko ime i naziv usluge uneseno

            return filteredQuery;
        }


        public override async Task<Model.Znacka> Insert(ZnackaInsertRequest insert)
        {
            // Kreiraj novi entitet na osnovu request-a
            var entity = _mapper.Map<Database.Znacka>(insert);

            // Postavi trenutni datum


            // Dodaj u bazu podataka
            _context.Znackas.Add(entity);
            await _context.SaveChangesAsync();

            // Vrati mapirani model
            return _mapper.Map<Model.Znacka>(entity);
        }


        public override async Task<Model.Znacka> Update(int id, ZnackaUpdateRequest update)
        {
            var entity = await _context.Znackas.FindAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException("Znacka nije pronađen.");
            }

            _mapper.Map(update, entity);


            _context.Znackas.Update(entity);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Znacka>(entity);
        }
        public override async Task<PagedResult<Model.Znacka>> Get(ZnackaSearchObject? search)
        {
            var result = await base.Get(search);


            if (search?.KorisnikId == null)
            {
                return result;
            }


            int korisnikId = search.KorisnikId.Value;


            // BROJ KNJIGA
            int brojKnjiga = await _context.Knjigas
                .CountAsync(x => x.KorisnikId == korisnikId);



            // BROJ CITATA
            int brojCitata = await _context.Citats
                .CountAsync(x =>
                    x.IdKnjigaNavigation.KorisnikId == korisnikId);



            // BROJ RAZLIČITIH ŽANROVA
            int brojZanrova = await _context.KnjigaZanrs
                .Where(x =>
                    x.IdKnjigaNavigation.KorisnikId == korisnikId)
                .Select(x => x.IdZanr)
                .Distinct()
                .CountAsync();



            // BROJ FAVORITA
            int brojFavorita = await _context.Knjigas
                .CountAsync(x =>
                    x.KorisnikId == korisnikId &&
                    x.IsFavorite == true);



            // BROJ RAZLIČITIH MOODOVA
            int brojMoodova = await _context.Knjigas
                .Where(x =>
                    x.KorisnikId == korisnikId &&
                    x.Mood != null)
                .Select(x => x.Mood)
                .Distinct()
                .CountAsync();



            // CURRENT STREAK
            var danas = DateTime.Today;


            var dani = await _context.Citats
                .Where(c =>
                    c.IdKnjigaNavigation.KorisnikId == korisnikId &&
                    c.DatumKreiranja.HasValue)
                .Select(c =>
                    c.DatumKreiranja.Value.Date)
                .Distinct()
                .OrderByDescending(x => x)
                .ToListAsync();



            int streak = 0;

            DateTime provjera = danas;


            foreach (var dan in dani)
            {
                if (dan == provjera)
                {
                    streak++;
                    provjera = provjera.AddDays(-1);
                }
                else if (dan < provjera)
                {
                    break;
                }
            }



            // POPUNI PROGRESS
            foreach (var znacka in result.Result)
            {
                switch (znacka.Tip)
                {
                    case "Books":
                        znacka.TrenutniNapredak = brojKnjiga;
                        break;


                    case "Quotes":
                        znacka.TrenutniNapredak = brojCitata;
                        break;


                    case "Genres":
                        znacka.TrenutniNapredak = brojZanrova;
                        break;


                    case "Favorites":
                        znacka.TrenutniNapredak = brojFavorita;
                        break;


                    case "Mood":
                        znacka.TrenutniNapredak = brojMoodova;
                        break;


                    case "Streak":
                        znacka.TrenutniNapredak = streak;
                        break;


                    default:
                        znacka.TrenutniNapredak = 0;
                        break;
                }
            }


            return result;
        }

    }
}
