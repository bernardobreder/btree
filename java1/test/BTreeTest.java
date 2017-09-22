import org.junit.Assert;
import org.junit.Test;

public class BTreeTest {

	private static final int MAX = 100;

	@Test
	public void testMain() throws Exception {
		BTree tree = new BTree();
		for (int n = 0; n < MAX; n++) {
			tree.add(n);
			Assert.assertTrue(tree.contains(n));
		}
		for (int n = 0; n < MAX; n++) {
			Assert.assertTrue(tree.contains(n));
		}
		for (int n = 0; n < MAX; n++) {
			tree.remove(n);
		}
		for (int n = 0; n < MAX; n++) {
			Assert.assertFalse(tree.contains(n));
		}
	}
	
}
