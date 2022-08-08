from unittest import TestCase

from MarkLearnsCoding.scripts.fast_cnki_translate.fast_cnki_translate import get_translation, query_translate

word = '封装'
topic_code = 'I138'


class Test(TestCase):
    def test_get_translation(self):
        res = get_translation(word, topic_code)
        self.assertIsNotNone(res)
        self.assertEqual(res[word]['code'], 200)


class Test(TestCase):
    def test_query_translate(self):
        word = "封装"
        res = query_translate(word)
        self.assertIsNotNone(res)
        self.assertEqual(res['code'], 200)
